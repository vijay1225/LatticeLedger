import React, { useState, useEffect, useRef } from 'react';
import { Zap, Send, Tag, FileText, Trash2, Clock, Sparkles, Edit2, Check, X, Layers, CornerDownRight } from 'lucide-react';
import { Note } from '../types';

interface QuickNotesFeedProps {
  quickNotes: Note[];
  activeNoteId?: string | null;
  onClearActiveNote?: () => void;
  onAddQuickNote: (content: string) => void;
  onUpdateQuickNote?: (id: string, content: string) => void;
  onDeleteQuickNote: (id: string) => void;
  onPromoteToWiki: (note: Note) => void;
  onTagClick?: (tag: string) => void;
  flashcardNoteIds?: Set<string>;
  onToggleFlashcard?: (noteId: string) => void;
}

export const QuickNotesFeed: React.FC<QuickNotesFeedProps> = ({
  quickNotes,
  activeNoteId,
  onClearActiveNote,
  onAddQuickNote,
  onUpdateQuickNote,
  onDeleteQuickNote,
  onPromoteToWiki,
  onTagClick,
  flashcardNoteIds,
  onToggleFlashcard
}) => {
  const [content, setContent] = useState('');
  const [selectedTag, setSelectedTag] = useState<string | null>(null);
  const [editingNoteId, setEditingNoteId] = useState<string | null>(null);
  const [editingText, setEditingText] = useState('');

  const containerRef = useRef<HTMLDivElement | null>(null);
  const noteRefs = useRef<Record<string, HTMLDivElement | null>>({});

  const activeTargetNote = activeNoteId ? quickNotes.find(n => n.id === activeNoteId) : null;

  // Auto-scroll and ensure targeted note is visible (clearing tag filter if necessary)
  useEffect(() => {
    if (activeNoteId) {
      const target = quickNotes.find(n => n.id === activeNoteId);
      if (target && selectedTag && !target.tags.includes(selectedTag)) {
        setSelectedTag(null);
      }

      const timer = setTimeout(() => {
        const el = noteRefs.current[activeNoteId];
        if (el) {
          el.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }, 100);

      return () => clearTimeout(timer);
    }
  }, [activeNoteId, quickNotes, selectedTag]);

  const allTags = Array.from(
    new Set(quickNotes.flatMap(n => n.tags))
  );

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;
    onAddQuickNote(content);
    setContent('');
  };

  const startEditing = (note: Note) => {
    setEditingNoteId(note.id);
    setEditingText(note.content);
  };

  const cancelEditing = () => {
    setEditingNoteId(null);
    setEditingText('');
  };

  const handleSaveEdit = (id: string) => {
    if (!editingText.trim()) return;
    onUpdateQuickNote?.(id, editingText);
    setEditingNoteId(null);
    setEditingText('');
  };

  const filteredNotes = selectedTag
    ? quickNotes.filter(n => n.tags.includes(selectedTag))
    : quickNotes;

  return (
    <div 
      ref={containerRef}
      className="flex-1 h-full overflow-y-auto px-4 sm:px-6 lg:px-12 py-6 pb-28 md:pb-12 max-w-4xl mx-auto w-full text-xs"
    >
      <div className="mb-5">
        <h2 className="text-xl font-bold tracking-tight text-zinc-100 flex items-center gap-2">
          <span>Quick Notes</span>
          <Zap className="w-4 h-4 text-amber-400" />
        </h2>
        <p className="text-xs text-zinc-500 mt-0.5">
          Zero-friction capture. Editable anytime. AI extracts keywords and tags automatically.
        </p>
      </div>

      {/* Target Quick Note Navigation Banner (When navigated from Search, Page, or Graph) */}
      {activeTargetNote && (
        <div className="mb-5 p-3 rounded-xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-between gap-3 text-xs animate-in fade-in slide-in-from-top-2 duration-200 shadow-sm">
          <div className="flex items-center gap-2.5 text-amber-200 min-w-0">
            <div className="p-1.5 rounded-lg bg-amber-500/20 text-amber-300 shrink-0">
              <Zap className="w-4 h-4 text-amber-400 fill-amber-400" />
            </div>
            <div className="min-w-0">
              <div className="font-semibold text-amber-300 flex items-center gap-2">
                <span>Navigated to Quick Note</span>
                <span className="text-[10px] px-1.5 py-0.5 rounded bg-amber-400/20 text-amber-300 border border-amber-400/30 font-mono">
                  Target
                </span>
              </div>
              <p className="text-zinc-300 text-[11px] truncate mt-0.5 font-mono">
                "{activeTargetNote.content.slice(0, 60)}{activeTargetNote.content.length > 60 ? '...' : ''}"
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2 shrink-0">
            <button
              type="button"
              onClick={() => {
                const el = noteRefs.current[activeTargetNote.id];
                el?.scrollIntoView({ behavior: 'smooth', block: 'center' });
              }}
              className="px-2.5 py-1 rounded-md bg-amber-500/20 hover:bg-amber-500/30 text-amber-200 text-[11px] font-medium transition-colors cursor-pointer flex items-center gap-1"
            >
              <CornerDownRight className="w-3 h-3" />
              <span>Scroll to Note</span>
            </button>
            {onClearActiveNote && (
              <button
                type="button"
                onClick={onClearActiveNote}
                className="px-2.5 py-1 rounded-md bg-zinc-800 hover:bg-zinc-700 text-zinc-300 text-[11px] transition-colors cursor-pointer"
                title="View all quick notes without filter"
              >
                Show All
              </button>
            )}
          </div>
        </div>
      )}

      {/* Input Box */}
      <form onSubmit={handleSubmit} className="mb-6">
        <div className="p-3 rounded-lg bg-zinc-900 border border-zinc-800 focus-within:border-zinc-700 transition-all">
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
                handleSubmit(e);
              }
            }}
            placeholder="Jot down a quick thought, observation, or snippet... (Ctrl+Enter to save)"
            className="w-full bg-transparent text-sm text-zinc-100 placeholder-zinc-600 focus:outline-none resize-none min-h-[65px]"
          />
          <div className="flex items-center justify-between pt-2 border-t border-zinc-800/60 mt-1">
            <span className="text-[11px] text-zinc-500 flex items-center gap-1">
              <Sparkles className="w-3 h-3 text-indigo-400" />
              <span>AI auto-tags on save</span>
            </span>
            <button
              type="submit"
              disabled={!content.trim()}
              className="px-3 py-1 rounded-md bg-zinc-100 hover:bg-white text-zinc-950 font-semibold text-xs flex items-center gap-1.5 disabled:opacity-40 transition-colors"
            >
              <span>Save Note</span>
              <Send className="w-3 h-3" />
            </button>
          </div>
        </div>
      </form>

      {/* Tag Filters */}
      {allTags.length > 0 && (
        <div className="mb-4 flex flex-wrap items-center gap-1.5">
          <button
            onClick={() => setSelectedTag(null)}
            className={`px-2 py-0.5 rounded text-xs transition-colors ${
              selectedTag === null
                ? 'bg-zinc-800 text-zinc-100 font-medium'
                : 'text-zinc-500 hover:text-zinc-300'
            }`}
          >
            All ({quickNotes.length})
          </button>
          {allTags.map((t, idx) => (
            <button
              key={idx}
              onClick={() => setSelectedTag(selectedTag === t ? null : t)}
              className={`px-2 py-0.5 rounded text-xs transition-colors ${
                selectedTag === t
                  ? 'bg-zinc-800 text-zinc-100 font-medium border border-zinc-700'
                  : 'text-zinc-500 hover:text-zinc-300'
              }`}
            >
              {t}
            </button>
          ))}
        </div>
      )}

      {/* Feed */}
      <div className="space-y-3">
        {filteredNotes.map((note) => {
          const isEditing = editingNoteId === note.id;
          const isActive = activeNoteId === note.id;

          return (
            <div
              key={note.id}
              id={`quick-note-${note.id}`}
              ref={(el) => { noteRefs.current[note.id] = el; }}
              className={`p-4 rounded-xl border transition-all duration-300 group ${
                isActive
                  ? 'bg-amber-950/20 border-amber-500/70 ring-2 ring-amber-400/90 shadow-xl shadow-amber-500/15'
                  : 'bg-zinc-900/50 border-zinc-800/80 hover:border-zinc-700/80'
              }`}
            >
              <div className="flex items-center justify-between text-zinc-500 mb-2">
                <div className="flex items-center gap-2 text-[11px]">
                  <div className="flex items-center gap-1">
                    <Clock className="w-3 h-3" />
                    <span>{new Date(note.createdAt).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
                  </div>
                  {isActive && (
                    <div className="flex items-center gap-1 px-2 py-0.5 rounded-full bg-amber-400/20 text-amber-300 border border-amber-400/40 text-[10px] font-semibold animate-pulse">
                      <Zap className="w-2.5 h-2.5 text-amber-400 fill-amber-400" />
                      <span>Target Note</span>
                    </div>
                  )}
                </div>
                <div className="flex items-center gap-1.5 opacity-70 group-hover:opacity-100 transition-opacity">
                  {onToggleFlashcard && (
                    <button
                      onClick={() => onToggleFlashcard(note.id)}
                      className={`px-1.5 py-0.5 rounded text-[11px] flex items-center gap-1 transition-colors ${
                        flashcardNoteIds?.has(note.id)
                          ? 'bg-emerald-950/40 text-emerald-300 border border-emerald-500/30'
                          : 'text-zinc-500 hover:text-zinc-200 hover:bg-zinc-800'
                      }`}
                      title={flashcardNoteIds?.has(note.id) ? "In Flashcards (click to remove)" : "Add to Flashcards"}
                    >
                      <Layers className="w-3 h-3 text-emerald-400" />
                      <span className="hidden sm:inline">{flashcardNoteIds?.has(note.id) ? 'In Flashcards' : 'Flashcard'}</span>
                    </button>
                  )}
                  {!isEditing && (
                    <button
                      onClick={() => startEditing(note)}
                      className="px-1.5 py-0.5 rounded text-[11px] text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800 flex items-center gap-1"
                      title="Edit Quick Note"
                    >
                      <Edit2 className="w-3 h-3 text-indigo-400" />
                      <span>Edit</span>
                    </button>
                  )}
                  <button
                    onClick={() => onPromoteToWiki(note)}
                    className="px-1.5 py-0.5 rounded text-[11px] text-zinc-400 hover:text-zinc-200 hover:bg-zinc-800 flex items-center gap-1"
                    title="Promote to Wiki Page"
                  >
                    <FileText className="w-3 h-3" />
                    <span>Convert to Page</span>
                  </button>
                  <button
                    onClick={() => onDeleteQuickNote(note.id)}
                    className="p-1 rounded text-zinc-600 hover:text-rose-400 transition-colors"
                    title="Delete"
                  >
                    <Trash2 className="w-3 h-3" />
                  </button>
                </div>
              </div>

              {isEditing ? (
                <div className="space-y-2 mt-1">
                  <textarea
                    value={editingText}
                    onChange={(e) => setEditingText(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
                        handleSaveEdit(note.id);
                      } else if (e.key === 'Escape') {
                        cancelEditing();
                      }
                    }}
                    rows={4}
                    className="w-full p-2.5 rounded-lg bg-zinc-950 border border-indigo-500/50 text-zinc-100 text-xs font-mono focus:outline-none focus:ring-1 focus:ring-indigo-500/50 resize-y"
                    autoFocus
                  />
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] text-zinc-500">
                      Press Ctrl+Enter to save, Esc to cancel
                    </span>
                    <div className="flex items-center gap-1.5">
                      <button
                        type="button"
                        onClick={cancelEditing}
                        className="px-2.5 py-1 rounded bg-zinc-800 hover:bg-zinc-700 text-zinc-300 text-[11px] flex items-center gap-1 transition-colors"
                      >
                        <X className="w-3 h-3" />
                        <span>Cancel</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => handleSaveEdit(note.id)}
                        disabled={!editingText.trim()}
                        className="px-2.5 py-1 rounded bg-indigo-600 hover:bg-indigo-500 disabled:opacity-40 text-white text-[11px] font-medium flex items-center gap-1 transition-colors shadow-sm"
                      >
                        <Check className="w-3 h-3" />
                        <span>Save</span>
                      </button>
                    </div>
                  </div>
                </div>
              ) : (
                <p 
                  onClick={() => startEditing(note)}
                  className="text-zinc-200 leading-relaxed text-xs whitespace-pre-wrap mb-2 cursor-pointer hover:text-zinc-100"
                  title="Click to edit"
                >
                  {note.content}
                </p>
              )}

              {note.tags.length > 0 && (
                <div className="flex flex-wrap items-center gap-1 pt-1.5 border-t border-zinc-800/40">
                  <Tag className="w-3 h-3 text-zinc-600 mr-0.5" />
                  {note.tags.map((tag, idx) => (
                    <button
                      key={idx}
                      onClick={() => {
                        setSelectedTag(tag);
                        onTagClick?.(tag);
                      }}
                      className="px-1.5 py-0.5 rounded bg-zinc-800 hover:bg-zinc-700 text-zinc-400 hover:text-zinc-200 text-[10px] transition-colors"
                    >
                      {tag}
                    </button>
                  ))}
                </div>
              )}
            </div>
          );
        })}

        {filteredNotes.length === 0 && (
          <div className="py-12 text-center rounded-xl border border-dashed border-zinc-800 bg-zinc-950/40 p-6 space-y-2">
            <Zap className="w-6 h-6 text-zinc-600 mx-auto" />
            <div className="text-zinc-400 text-xs font-medium">No quick notes yet</div>
            <p className="text-[11px] text-zinc-600 max-w-xs mx-auto">
              Capture quick thoughts, ideas, and snippets using the input box above. AI will extract tags automatically.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};
