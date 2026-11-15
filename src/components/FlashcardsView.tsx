import React, { useState, useMemo } from 'react';
import { 
  Layers, 
  CheckCircle2, 
  Clock, 
  ExternalLink, 
  RotateCcw, 
  Trash2, 
  Award, 
  ChevronRight, 
  ChevronLeft,
  Sparkles,
  BookOpen,
  ArrowRight,
  Zap,
  Tag
} from 'lucide-react';
import { Note, Flashcard } from '../types';
import { 
  isFlashcardDue, 
  getStageDescription, 
  getTodayDateStr,
  advanceFlashcard,
  resetFlashcard
} from '../services/flashcardService';
import { MarkdownViewer } from './MarkdownViewer';

interface FlashcardsViewProps {
  flashcards: Flashcard[];
  notes: Note[];
  onUpdateFlashcard: (card: Flashcard) => void;
  onRemoveFlashcard: (noteId: string) => void;
  onOpenNote: (noteId: string) => void;
}

export const FlashcardsView: React.FC<FlashcardsViewProps> = ({
  flashcards,
  notes,
  onUpdateFlashcard,
  onRemoveFlashcard,
  onOpenNote
}) => {
  const [activeTab, setActiveTab] = useState<'due' | 'all'>('due');
  const [currentDueIndex, setCurrentDueIndex] = useState(0);
  const [justReviewedId, setJustReviewedId] = useState<string | null>(null);

  const notesMap = useMemo(() => {
    const map = new Map<string, Note>();
    for (const n of notes) {
      map.set(n.id, n);
    }
    return map;
  }, [notes]);

  const todayStr = useMemo(() => getTodayDateStr(), []);

  // Separate due cards vs upcoming/mastered
  const dueCards = useMemo(() => {
    return flashcards.filter(c => isFlashcardDue(c, todayStr) && notesMap.has(c.noteId));
  }, [flashcards, todayStr, notesMap]);

  const activeUpcomingCards = useMemo(() => {
    return flashcards.filter(c => c.status === 'active' && !isFlashcardDue(c, todayStr) && notesMap.has(c.noteId));
  }, [flashcards, todayStr, notesMap]);

  const masteredCards = useMemo(() => {
    return flashcards.filter(c => c.status === 'mastered' && notesMap.has(c.noteId));
  }, [flashcards, notesMap]);

  // Clamp current index when due cards change
  const safeIndex = Math.min(currentDueIndex, Math.max(0, dueCards.length - 1));
  const currentCard = dueCards[safeIndex];
  const currentNote = currentCard ? notesMap.get(currentCard.noteId) : undefined;

  const handleMarkReviewed = (card: Flashcard) => {
    setJustReviewedId(card.id);
    const updated = advanceFlashcard(card);
    onUpdateFlashcard(updated);

    setTimeout(() => {
      setJustReviewedId(null);
      if (safeIndex >= dueCards.length - 1) {
        setCurrentDueIndex(Math.max(0, dueCards.length - 2));
      }
    }, 300);
  };

  const handleReset = (card: Flashcard) => {
    const reset = resetFlashcard(card);
    onUpdateFlashcard(reset);
  };

  return (
    <div className="flex-1 h-full min-h-0 overflow-y-auto block select-text bg-zinc-950 text-zinc-100 pb-36 md:pb-16">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 py-6 w-full">
        {/* Header */}
        <div className="mb-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-zinc-800/80 pb-4">
          <div>
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400">
                <Layers className="w-4 h-4" />
              </div>
              <h1 className="text-xl sm:text-2xl font-bold tracking-tight text-zinc-100">
                Flashcards & Spaced Repetition
              </h1>
            </div>
            <p className="text-xs text-zinc-400 mt-1">
              Revisit key notes across expanding intervals (Next Day &rarr; 7 Days &rarr; 1 Month &rarr; Mastered).
            </p>
          </div>

          {/* Tab Selector */}
          <div className="flex items-center bg-zinc-900 border border-zinc-800 p-1 rounded-lg text-xs self-start sm:self-auto">
            <button
              onClick={() => setActiveTab('due')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md font-medium transition-all ${
                activeTab === 'due'
                  ? 'bg-zinc-800 text-emerald-400 shadow-sm border border-zinc-700/60 font-semibold'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <span>Due Today</span>
              {dueCards.length > 0 && (
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              )}
              <span className={`px-1.5 py-0.2 rounded-full text-[10px] ${
                activeTab === 'due' ? 'bg-emerald-500/20 text-emerald-300' : 'bg-zinc-800 text-zinc-400'
              }`}>
                {dueCards.length}
              </span>
            </button>

            <button
              onClick={() => setActiveTab('all')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md font-medium transition-all ${
                activeTab === 'all'
                  ? 'bg-zinc-800 text-zinc-100 shadow-sm border border-zinc-700/60 font-semibold'
                  : 'text-zinc-400 hover:text-zinc-200'
              }`}
            >
              <span>All Cards</span>
              <span className={`px-1.5 py-0.2 rounded-full text-[10px] ${
                activeTab === 'all' ? 'bg-zinc-700 text-zinc-200' : 'bg-zinc-800 text-zinc-400'
              }`}>
                {flashcards.length}
              </span>
            </button>
          </div>
        </div>

        {/* TAB 1: DUE TODAY (FOCUS READER MODE) */}
        {activeTab === 'due' && (
          <div>
            {dueCards.length === 0 ? (
              <div className="text-center py-16 px-4 bg-zinc-900/40 rounded-2xl border border-zinc-800/80 max-w-lg mx-auto space-y-3">
                <div className="w-12 h-12 rounded-full bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center mx-auto text-emerald-400">
                  <CheckCircle2 className="w-6 h-6" />
                </div>
                <h3 className="text-base font-semibold text-zinc-200">You're all caught up for today! 🎉</h3>
                <p className="text-xs text-zinc-400 max-w-sm mx-auto leading-relaxed">
                  No notes are waiting for review right now. The WhatsApp-style notification dot is clear until your next scheduled review day arrives.
                </p>
                {activeUpcomingCards.length > 0 && (
                  <div className="pt-2">
                    <button
                      onClick={() => setActiveTab('all')}
                      className="text-xs text-indigo-400 hover:text-indigo-300 font-medium inline-flex items-center gap-1 transition-colors"
                    >
                      <span>View {activeUpcomingCards.length} upcoming scheduled cards</span>
                      <ArrowRight className="w-3.5 h-3.5" />
                    </button>
                  </div>
                )}
              </div>
            ) : currentCard && currentNote ? (
              <div className="space-y-4">
                {/* Progress Bar & Counter */}
                <div className="flex items-center justify-between text-xs text-zinc-400 px-1">
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-zinc-200">
                      Card {safeIndex + 1} of {dueCards.length}
                    </span>
                    <span className="text-zinc-600">&bull;</span>
                    <span className="text-emerald-400 font-medium flex items-center gap-1">
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      Due for Review
                    </span>
                  </div>

                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => setCurrentDueIndex(prev => Math.max(0, prev - 1))}
                      disabled={safeIndex === 0}
                      className="p-1 rounded hover:bg-zinc-800 text-zinc-400 hover:text-zinc-200 disabled:opacity-30 transition-colors"
                      title="Previous Card"
                    >
                      <ChevronLeft className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => setCurrentDueIndex(prev => Math.min(dueCards.length - 1, prev + 1))}
                      disabled={safeIndex === dueCards.length - 1}
                      className="p-1 rounded hover:bg-zinc-800 text-zinc-400 hover:text-zinc-200 disabled:opacity-30 transition-colors"
                      title="Next Card"
                    >
                      <ChevronRight className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                {/* Progress track */}
                <div className="w-full bg-zinc-850 h-1.5 rounded-full overflow-hidden">
                  <div 
                    className="bg-emerald-500 h-full transition-all duration-300 rounded-full"
                    style={{ width: `${((safeIndex + 1) / dueCards.length) * 100}%` }}
                  />
                </div>

                {/* Full-Screen Reading Card */}
                <div 
                  className={`bg-zinc-900 border rounded-2xl p-5 sm:p-7 transition-all shadow-xl ${
                    justReviewedId === currentCard.id 
                      ? 'border-emerald-500/80 bg-emerald-950/20 scale-[0.99] opacity-70' 
                      : 'border-zinc-800/80'
                  }`}
                >
                  {/* Card Stage & Metadata Badge */}
                  <div className="flex items-center justify-between gap-3 flex-wrap pb-4 border-b border-zinc-800/80 mb-4">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="px-2 py-0.5 rounded-md bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 text-[11px] font-semibold flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        <span>{getStageDescription(currentCard.stage).badge}</span>
                      </span>

                      <span className="px-2 py-0.5 rounded-md bg-zinc-800 border border-zinc-700/60 text-zinc-300 text-[11px] font-medium flex items-center gap-1">
                        {currentNote.type === 'wiki' ? <BookOpen className="w-3 h-3 text-indigo-400" /> : <Zap className="w-3 h-3 text-amber-400" />}
                        <span className="capitalize">{currentNote.type === 'wiki' ? 'Wiki Page' : 'Quick Note'}</span>
                      </span>

                      <span className="text-[11px] text-zinc-500">
                        Next: {getStageDescription(currentCard.stage).nextInterval}
                      </span>
                    </div>

                    <button
                      onClick={() => onOpenNote(currentNote.id)}
                      className="text-xs text-indigo-400 hover:text-indigo-300 font-medium inline-flex items-center gap-1 px-2.5 py-1 rounded-md bg-indigo-500/10 hover:bg-indigo-500/20 border border-indigo-500/20 transition-colors"
                      title="Open full note in editor"
                    >
                      <span>Open Note</span>
                      <ExternalLink className="w-3 h-3" />
                    </button>
                  </div>

                  {/* Title */}
                  <h2 className="text-xl sm:text-2xl font-bold tracking-tight text-zinc-100 mb-3">
                    {currentNote.title || 'Untitled'}
                  </h2>

                  {/* AI Summary Highlight (if generated) */}
                  {currentNote.summary && (
                    <div className="mb-4 p-3.5 rounded-xl bg-indigo-950/20 border border-indigo-500/20 text-xs">
                      <div className="flex items-center gap-1.5 text-indigo-300 font-semibold mb-1.5">
                        <Sparkles className="w-3.5 h-3.5" />
                        <span>Key Takeaways</span>
                      </div>
                      <ul className="space-y-1 text-zinc-300 list-disc list-inside">
                        {(currentNote.summary.tldr || []).slice(0, 3).map((pt, i) => (
                          <li key={i} className="leading-relaxed">{pt}</li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Note Content (Distraction-Free Formatted Markdown) */}
                  <div className="prose prose-invert max-w-none text-zinc-200 text-sm leading-relaxed overflow-x-auto min-h-[120px] max-h-[460px] overflow-y-auto pr-2">
                    <MarkdownViewer content={currentNote.content} />
                  </div>

                  {/* Tags */}
                  {currentNote.tags && currentNote.tags.length > 0 && (
                    <div className="mt-4 pt-3 border-t border-zinc-800/60 flex items-center gap-1.5 flex-wrap">
                      <Tag className="w-3 h-3 text-zinc-600 mr-0.5" />
                      {currentNote.tags.map((tag, i) => (
                        <span key={i} className="px-2 py-0.5 rounded bg-zinc-800/80 text-zinc-400 text-[10px]">
                          {tag}
                        </span>
                      ))}
                    </div>
                  )}

                  {/* Dedicated Bottom Review Action */}
                  <div className="mt-6 pt-5 border-t border-zinc-800/80 flex items-center justify-between gap-4">
                    <button
                      onClick={() => onRemoveFlashcard(currentNote.id)}
                      className="text-xs text-zinc-500 hover:text-rose-400 p-2 rounded-lg hover:bg-zinc-800 transition-colors flex items-center gap-1.5"
                      title="Remove from Flashcards"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                      <span className="hidden sm:inline">Remove from Flashcards</span>
                    </button>

                    <button
                      onClick={() => handleMarkReviewed(currentCard)}
                      className="w-full sm:w-auto px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-semibold text-sm flex items-center justify-center gap-2 shadow-lg shadow-emerald-950/50 active:scale-95 transition-all"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      <span>Mark as Reviewed ✅</span>
                    </button>
                  </div>
                </div>
              </div>
            ) : null}
          </div>
        )}

        {/* TAB 2: ALL CARDS & MASTERED ARCHIVE */}
        {activeTab === 'all' && (
          <div className="space-y-8">
            {/* 1. Active In-Progress Flashcards */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold text-zinc-300 uppercase tracking-wider flex items-center gap-2">
                  <Clock className="w-4 h-4 text-zinc-400" />
                  <span>Active Review Queue ({activeUpcomingCards.length + dueCards.length})</span>
                </h3>
              </div>

              {activeUpcomingCards.length === 0 && dueCards.length === 0 ? (
                <div className="py-8 text-center bg-zinc-900/30 rounded-xl border border-zinc-800 text-xs text-zinc-500">
                  No active flashcards right now. Add any page or quick note to flashcards using the option in the note header.
                </div>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {[...dueCards, ...activeUpcomingCards].map(card => {
                    const note = notesMap.get(card.noteId);
                    if (!note) return null;
                    const isDue = isFlashcardDue(card, todayStr);
                    const desc = getStageDescription(card.stage);

                    return (
                      <div 
                        key={card.id}
                        className={`p-3.5 rounded-xl border transition-all ${
                          isDue 
                            ? 'bg-emerald-950/15 border-emerald-500/40' 
                            : 'bg-zinc-900 border-zinc-800/80 hover:border-zinc-700'
                        }`}
                      >
                        <div className="flex items-start justify-between gap-2 mb-1.5">
                          <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full ${
                            isDue 
                              ? 'bg-emerald-500/20 text-emerald-300' 
                              : 'bg-zinc-800 text-zinc-400'
                          }`}>
                            {isDue ? '● Due Today' : `Due: ${card.nextReviewDate}`}
                          </span>

                          <span className="text-[10px] text-zinc-500 font-medium">
                            {desc.name} ({desc.interval})
                          </span>
                        </div>

                        <h4 
                          onClick={() => onOpenNote(note.id)}
                          className="font-semibold text-zinc-100 text-sm hover:text-indigo-300 cursor-pointer truncate mb-1"
                        >
                          {note.title || 'Untitled'}
                        </h4>

                        <p className="text-xs text-zinc-400 line-clamp-2 mb-3">
                          {note.content}
                        </p>

                        <div className="flex items-center justify-between pt-2 border-t border-zinc-800/60 text-xs">
                          <button
                            onClick={() => onOpenNote(note.id)}
                            className="text-[11px] text-indigo-400 hover:text-indigo-300 flex items-center gap-1 font-medium"
                          >
                            <span>Open</span>
                            <ExternalLink className="w-3 h-3" />
                          </button>

                          <div className="flex items-center gap-2">
                            <button
                              onClick={() => onRemoveFlashcard(note.id)}
                              className="text-[11px] text-zinc-500 hover:text-rose-400"
                              title="Remove"
                            >
                              Remove
                            </button>
                            {isDue && (
                              <button
                                onClick={() => handleMarkReviewed(card)}
                                className="px-2 py-0.5 rounded bg-emerald-600 hover:bg-emerald-500 text-white font-medium text-[11px] flex items-center gap-1 shadow-sm"
                              >
                                <CheckCircle2 className="w-3 h-3" />
                                <span>Review</span>
                              </button>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            {/* 2. Mastered Archive */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold text-amber-400 uppercase tracking-wider flex items-center gap-2">
                  <Award className="w-4 h-4 text-amber-400" />
                  <span>Mastered Archive ({masteredCards.length})</span>
                </h3>
              </div>

              {masteredCards.length === 0 ? (
                <div className="py-8 text-center bg-zinc-900/30 rounded-xl border border-zinc-800 text-xs text-zinc-500">
                  Notes that complete the 1-month review graduate here into your Mastered Archive.
                </div>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {masteredCards.map(card => {
                    const note = notesMap.get(card.noteId);
                    if (!note) return null;

                    return (
                      <div 
                        key={card.id}
                        className="p-3.5 rounded-xl border border-zinc-800 bg-zinc-900/70 space-y-2"
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-amber-500/15 text-amber-300 border border-amber-500/30 flex items-center gap-1">
                            <Award className="w-3 h-3" />
                            <span>Mastered</span>
                          </span>

                          <span className="text-[10px] text-zinc-500">
                            Completed 1-month cycle
                          </span>
                        </div>

                        <h4 
                          onClick={() => onOpenNote(note.id)}
                          className="font-semibold text-zinc-100 text-sm hover:text-indigo-300 cursor-pointer truncate"
                        >
                          {note.title || 'Untitled'}
                        </h4>

                        <div className="flex items-center justify-between pt-2 border-t border-zinc-800/60 text-xs">
                          <button
                            onClick={() => handleReset(card)}
                            className="text-[11px] text-zinc-400 hover:text-zinc-200 flex items-center gap-1"
                            title="Re-add to Stage 1 to study again"
                          >
                            <RotateCcw className="w-3 h-3" />
                            <span>Re-study from Day 1</span>
                          </button>

                          <button
                            onClick={() => onRemoveFlashcard(note.id)}
                            className="text-[11px] text-zinc-500 hover:text-rose-400"
                          >
                            Remove
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
