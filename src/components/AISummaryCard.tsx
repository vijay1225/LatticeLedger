import React, { useState } from 'react';
import { Sparkles, Copy, Check, RefreshCw, Key, AlertCircle } from 'lucide-react';
import { AISummary } from '../types';

interface AISummaryCardProps {
  summary?: AISummary;
  onRefresh: () => void;
  isLoading: boolean;
  onTagClick?: (tag: string) => void;
  hasApiKey?: boolean;
  onOpenSettings?: () => void;
  errorMessage?: string | null;
}

export const AISummaryCard: React.FC<AISummaryCardProps> = ({
  summary,
  onRefresh,
  isLoading,
  onTagClick,
  hasApiKey = true,
  onOpenSettings,
  errorMessage
}) => {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    if (!summary) return;
    const parts: string[] = [];
    if (summary.tldr && summary.tldr.length > 0) {
      parts.push(`AI Summary:\n${summary.tldr.map(p => `• ${p}`).join('\n')}`);
    }
    if (summary.actionItems && summary.actionItems.length > 0) {
      parts.push(`Action Items:\n${summary.actionItems.map(a => `✓ ${a}`).join('\n')}`);
    }
    if (summary.tags && summary.tags.length > 0) {
      parts.push(`Tags: ${summary.tags.map(t => `#${t}`).join(' ')}`);
    }
    navigator.clipboard.writeText(parts.join('\n\n'));
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  // Proportional takeaways: renders full concise or comprehensive points
  const takeaways = summary?.tldr || [];

  return (
    <div className="mb-4 rounded-lg border border-zinc-800 bg-zinc-900/70 p-3 text-xs shadow-sm">
      {/* Top Header Bar */}
      <div className="flex items-center justify-between mb-1.5 pb-1.5 border-b border-zinc-800/60">
        <div className="flex items-center gap-2">
          <div className="flex items-center gap-1.5 px-1.5 py-0.5 rounded bg-indigo-500/10 text-indigo-400 font-medium text-[11px] border border-indigo-500/20">
            <Sparkles className="w-3 h-3 text-indigo-400" />
            <span>AI Summary</span>
          </div>
          <span className={`text-[10px] ${hasApiKey ? 'text-zinc-500' : 'text-amber-400/80 font-medium'}`}>
            {summary?.model || (hasApiKey ? 'Gemini Active' : 'Key Required')}
          </span>
        </div>

        <div className="flex items-center gap-1.5">
          {summary && (
            <button
              onClick={handleCopy}
              className="p-1 rounded text-zinc-500 hover:text-zinc-300 hover:bg-zinc-800 transition-colors"
              title="Copy summary"
            >
              {copied ? <Check className="w-3 h-3 text-emerald-400" /> : <Copy className="w-3 h-3" />}
            </button>
          )}

          {hasApiKey ? (
            <button
              onClick={onRefresh}
              disabled={isLoading}
              className="px-2 py-0.5 rounded bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-600 text-zinc-300 hover:text-zinc-100 text-[11px] font-medium flex items-center gap-1 transition-colors disabled:opacity-40"
              title="Generate / Refresh summary with Gemini"
            >
              <RefreshCw className={`w-2.5 h-2.5 ${isLoading ? 'animate-spin text-indigo-400' : ''}`} />
              <span>{isLoading ? 'Synthesizing...' : summary ? 'Refresh' : 'Generate'}</span>
            </button>
          ) : (
            <button
              onClick={onOpenSettings}
              className="px-2 py-0.5 rounded bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/30 text-amber-300 text-[11px] font-medium flex items-center gap-1 transition-colors"
              title="Open Settings to add Gemini API Key"
            >
              <Key className="w-2.5 h-2.5" />
              <span>Add Key</span>
            </button>
          )}
        </div>
      </div>

      {/* Main Content */}
      {isLoading ? (
        <div className="py-2 text-zinc-400 flex items-center gap-2">
          <Sparkles className="w-3.5 h-3.5 text-indigo-400 animate-spin" />
          <span>Generating structured summary with Gemini AI...</span>
        </div>
      ) : errorMessage ? (
        <div className="py-1.5 text-amber-300/90 flex items-center justify-between gap-2">
          <div className="flex items-center gap-1.5 overflow-hidden">
            <AlertCircle className="w-3.5 h-3.5 text-amber-400 shrink-0" />
            <span className="truncate text-[11px]">{errorMessage}</span>
          </div>
          {onOpenSettings && (
            <button
              onClick={onOpenSettings}
              className="text-indigo-400 hover:text-indigo-300 text-[11px] font-medium underline shrink-0"
            >
              Settings
            </button>
          )}
        </div>
      ) : summary && takeaways.length > 0 ? (
        <div className="space-y-2.5">
          {/* Key Takeaways (Full text visible, zero clipping on mobile/desktop) */}
          <ul className="space-y-2 text-zinc-200 text-xs sm:text-[13px] leading-relaxed">
            {takeaways.map((point, idx) => (
              <li key={idx} className="flex items-start gap-2">
                <span className="text-indigo-400 font-bold shrink-0 mt-0.5">•</span>
                <span className="flex-1 break-words select-text text-zinc-200 leading-relaxed font-normal">
                  {point}
                </span>
              </li>
            ))}
          </ul>

          {/* Action Items (if any extracted) */}
          {summary.actionItems && summary.actionItems.length > 0 && (
            <div className="pt-2 border-t border-zinc-800/60 mt-2 space-y-1.5">
              <div className="text-[10px] font-semibold text-amber-400/90 uppercase tracking-wider flex items-center gap-1">
                <span>Action Items</span>
              </div>
              <ul className="space-y-1.5 text-zinc-300 text-xs sm:text-[13px] leading-relaxed">
                {summary.actionItems.map((action, idx) => (
                  <li key={idx} className="flex items-start gap-2">
                    <span className="text-amber-400 font-bold shrink-0 mt-0.5">✓</span>
                    <span className="flex-1 break-words select-text text-zinc-300 leading-relaxed">
                      {action}
                    </span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Interactive Tags */}
          {summary.tags && summary.tags.length > 0 && (
            <div className="flex items-center gap-1.5 pt-2 border-t border-zinc-800/40 flex-wrap text-[11px]">
              <span className="text-zinc-500 font-mono text-[10px] shrink-0">TAGS:</span>
              {summary.tags.map((tag, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => onTagClick?.(tag)}
                  className="px-2 py-0.5 rounded-md bg-zinc-800/90 hover:bg-zinc-700 active:bg-zinc-600 text-zinc-300 hover:text-white text-[10px] font-medium transition-colors"
                >
                  #{tag}
                </button>
              ))}
            </div>
          )}
        </div>
      ) : !hasApiKey ? (
        <div className="py-1 text-zinc-400 text-xs flex items-center justify-between">
          <div className="flex items-center gap-1.5 text-zinc-400">
            <Key className="w-3.5 h-3.5 text-amber-400/80 shrink-0" />
            <span>Gemini API Key required to generate AI summaries.</span>
          </div>
          <button
            onClick={onOpenSettings}
            className="text-indigo-400 hover:text-indigo-300 font-medium underline shrink-0 ml-2"
          >
            Configure in Settings
          </button>
        </div>
      ) : (
        <div className="py-1 text-zinc-500 text-xs flex items-center justify-between">
          <span>No AI summary generated yet.</span>
          <button
            onClick={onRefresh}
            className="text-indigo-400 hover:text-indigo-300 font-medium underline"
          >
            Generate with Gemini
          </button>
        </div>
      )}
    </div>
  );
};
