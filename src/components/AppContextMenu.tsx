import React, { useState, useEffect, useRef } from 'react';
import { Copy, Check, Clipboard, Scissors, CornerDownLeft } from 'lucide-react';
import { isMarkdownText } from '../utils/wikiLinks';
import { convertMarkdownToHtml } from '../utils/markdownParser';

interface MenuState {
  isOpen: boolean;
  x: number;
  y: number;
  textToCopy: string;
  isSelection: boolean;
  isEditable: boolean;
  targetElement: HTMLElement | null;
}

export const AppContextMenu: React.FC = () => {
  const [menu, setMenu] = useState<MenuState>({
    isOpen: false,
    x: 0,
    y: 0,
    textToCopy: '',
    isSelection: false,
    isEditable: false,
    targetElement: null
  });

  const [copied, setCopied] = useState(false);
  const touchTimerRef = useRef<NodeJS.Timeout | null>(null);
  const touchStartPosRef = useRef({ x: 0, y: 0 });
  const menuRef = useRef<HTMLDivElement | null>(null);

  // Helper to extract relevant copyable text from target element or selection
  const extractCopyContext = (target: HTMLElement | null): { text: string; isSelection: boolean; isEditable: boolean } => {
    // 1. Check window selection
    const selection = window.getSelection();
    const selectedText = selection ? selection.toString().trim() : '';
    if (selectedText) {
      const isEditable = target ? (
        target.isContentEditable ||
        target.tagName === 'INPUT' ||
        target.tagName === 'TEXTAREA' ||
        Boolean(target.closest('.tiptap.ProseMirror'))
      ) : false;
      return { text: selectedText, isSelection: true, isEditable };
    }

    if (!target) return { text: '', isSelection: false, isEditable: false };

    const isEditable = (
      target.isContentEditable ||
      target.tagName === 'INPUT' ||
      target.tagName === 'TEXTAREA' ||
      Boolean(target.closest('.tiptap.ProseMirror'))
    );

    // If input or textarea
    if (target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') {
      const val = (target as HTMLInputElement | HTMLTextAreaElement).value?.trim() || '';
      return { text: val, isSelection: false, isEditable: true };
    }

    // If inside a code block
    const codeBlock = target.closest('pre, code');
    if (codeBlock) {
      return { text: codeBlock.textContent?.trim() || '', isSelection: false, isEditable };
    }

    // If inside a Quick Note card or list item
    const noteCard = target.closest('[id^="quick-note-"], .quick-note-card');
    if (noteCard) {
      const p = noteCard.querySelector('p, .prose');
      const text = p?.textContent?.trim() || noteCard.textContent?.trim() || '';
      return { text, isSelection: false, isEditable };
    }

    // If inside an AI summary card or blockquote
    const quoteOrSummary = target.closest('blockquote, .ai-summary-card');
    if (quoteOrSummary) {
      return { text: quoteOrSummary.textContent?.trim() || '', isSelection: false, isEditable };
    }

    // Default to the clicked element's text (if reasonable length)
    const raw = target.innerText?.trim() || target.textContent?.trim() || '';
    if (raw && raw.length > 0 && raw.length < 5000) {
      return { text: raw, isSelection: false, isEditable };
    }

    return { text: '', isSelection: false, isEditable };
  };

  const openMenuAt = (clientX: number, clientY: number, target: HTMLElement | null): boolean => {
    // Never trigger on graph canvas which has its own graph node context menu
    if (target?.closest('.knowledge-graph-canvas') || target?.tagName === 'CANVAS') {
      return false;
    }

    const { text, isSelection, isEditable } = extractCopyContext(target);

    // Only open if there is text to copy or the field is editable (for paste)
    if (!text && !isEditable) {
      return false;
    }

    // Position menu clamping to viewport
    const menuWidth = 170;
    const menuHeight = 110;
    const clampedX = Math.min(Math.max(12, clientX), window.innerWidth - menuWidth - 12);
    // On mobile touch, if near bottom, open slightly above finger
    let clampedY = clientY + 10;
    if (clampedY + menuHeight > window.innerHeight - 20) {
      clampedY = Math.max(12, clientY - menuHeight - 10);
    }

    setCopied(false);
    setMenu({
      isOpen: true,
      x: clampedX,
      y: clampedY,
      textToCopy: text,
      isSelection,
      isEditable,
      targetElement: target
    });

    return true;
  };

  // Right-click contextmenu event listener (Desktop + Browser)
  useEffect(() => {
    const handleContextMenu = (e: MouseEvent) => {
      // Don't intercept if modifier keys held or on graph
      if (e.ctrlKey || e.metaKey || (e.target as HTMLElement)?.closest('.knowledge-graph-canvas')) {
        return;
      }

      const opened = openMenuAt(e.clientX, e.clientY, e.target as HTMLElement);
      if (opened) {
        e.preventDefault();
      }
    };

    window.addEventListener('contextmenu', handleContextMenu);
    return () => window.removeEventListener('contextmenu', handleContextMenu);
  }, []);

  // Long-press Touch Event Listeners (Mobile / Tablet / Touchscreen)
  useEffect(() => {
    const handleTouchStart = (e: TouchEvent) => {
      if (e.touches.length !== 1) return;
      const touch = e.touches[0];
      touchStartPosRef.current = { x: touch.clientX, y: touch.clientY };

      if (touchTimerRef.current) {
        clearTimeout(touchTimerRef.current);
      }

      touchTimerRef.current = setTimeout(() => {
        // Haptic feedback if supported on mobile
        try {
          if (navigator.vibrate) navigator.vibrate(35);
        } catch {}

        openMenuAt(touch.clientX, touch.clientY, e.target as HTMLElement);
        touchTimerRef.current = null;
      }, 420); // 420ms long press threshold
    };

    const handleTouchMove = (e: TouchEvent) => {
      if (touchTimerRef.current && e.touches.length === 1) {
        const touch = e.touches[0];
        const dist = Math.hypot(
          touch.clientX - touchStartPosRef.current.x,
          touch.clientY - touchStartPosRef.current.y
        );
        // Cancel if user is scrolling
        if (dist > 8) {
          clearTimeout(touchTimerRef.current);
          touchTimerRef.current = null;
        }
      }
    };

    const handleTouchEnd = () => {
      if (touchTimerRef.current) {
        clearTimeout(touchTimerRef.current);
        touchTimerRef.current = null;
      }
    };

    window.addEventListener('touchstart', handleTouchStart, { passive: true });
    window.addEventListener('touchmove', handleTouchMove, { passive: true });
    window.addEventListener('touchend', handleTouchEnd, { passive: true });
    window.addEventListener('touchcancel', handleTouchEnd, { passive: true });

    return () => {
      window.removeEventListener('touchstart', handleTouchStart);
      window.removeEventListener('touchmove', handleTouchMove);
      window.removeEventListener('touchend', handleTouchEnd);
      window.removeEventListener('touchcancel', handleTouchEnd);
    };
  }, []);

  // Close menu on click outside, scroll, or Escape key
  useEffect(() => {
    if (!menu.isOpen) return;

    const handleClickOutside = (e: MouseEvent | TouchEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setMenu(prev => ({ ...prev, isOpen: false }));
      }
    };

    const handleScroll = () => {
      setMenu(prev => ({ ...prev, isOpen: false }));
    };

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setMenu(prev => ({ ...prev, isOpen: false }));
      }
    };

    window.addEventListener('mousedown', handleClickOutside);
    window.addEventListener('touchstart', handleClickOutside);
    window.addEventListener('scroll', handleScroll, { passive: true, capture: true });
    window.addEventListener('keydown', handleKeyDown);

    return () => {
      window.removeEventListener('mousedown', handleClickOutside);
      window.removeEventListener('touchstart', handleClickOutside);
      window.removeEventListener('scroll', handleScroll, { capture: true });
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [menu.isOpen]);

  const handleCopy = async () => {
    if (!menu.textToCopy) return;
    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(menu.textToCopy);
      } else {
        const textarea = document.createElement('textarea');
        textarea.value = menu.textToCopy;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
      }

      setCopied(true);
      setTimeout(() => {
        setMenu(prev => ({ ...prev, isOpen: false }));
        setCopied(false);
      }, 500);
    } catch (err) {
      console.warn('[ContextMenu] Failed to copy to clipboard:', err);
      setMenu(prev => ({ ...prev, isOpen: false }));
    }
  };

  const handleCut = async () => {
    if (!menu.textToCopy) return;
    await handleCopy();
    if (menu.isEditable && menu.targetElement) {
      document.execCommand('delete');
    }
  };

  const handlePaste = async () => {
    try {
      if (navigator.clipboard && navigator.clipboard.readText) {
        const text = await navigator.clipboard.readText();
        if (text) {
          const target = menu.targetElement;
          const prosemirror = target?.closest?.('.tiptap.ProseMirror') as HTMLElement | null;

          // If pasting into TipTap WYSIWYG editor and text contains markdown formatting:
          if (prosemirror && isMarkdownText(text)) {
            try {
              const html = convertMarkdownToHtml(text);
              if (html) {
                // Try execCommand('insertHTML') which triggers ProseMirror's HTML DOM parser
                const inserted = document.execCommand('insertHTML', false, html);
                if (inserted) {
                  setMenu(prev => ({ ...prev, isOpen: false }));
                  return;
                }
              }
            } catch (err) {
              console.warn('[ContextMenu] insertHTML markdown paste fallback:', err);
            }
          }

          document.execCommand('insertText', false, text);
        }
      }
      setMenu(prev => ({ ...prev, isOpen: false }));
    } catch (err) {
      console.warn('[ContextMenu] Failed to read clipboard:', err);
      setMenu(prev => ({ ...prev, isOpen: false }));
    }
  };

  const handleSelectAll = () => {
    if (menu.targetElement) {
      if (menu.targetElement.tagName === 'INPUT' || menu.targetElement.tagName === 'TEXTAREA') {
        (menu.targetElement as HTMLInputElement | HTMLTextAreaElement).select();
      } else {
        const range = document.createRange();
        range.selectNodeContents(menu.targetElement);
        const sel = window.getSelection();
        sel?.removeAllRanges();
        sel?.addRange(range);
      }
    }
    setMenu(prev => ({ ...prev, isOpen: false }));
  };

  if (!menu.isOpen) return null;

  return (
    <div
      ref={menuRef}
      style={{ left: `${menu.x}px`, top: `${menu.y}px` }}
      className="fixed z-50 min-w-[160px] bg-zinc-900/95 backdrop-blur-md border border-zinc-700/80 rounded-xl shadow-2xl p-1 text-xs text-zinc-200 animate-in fade-in duration-150 select-none"
    >
      <div className="flex flex-col space-y-0.5">
        {/* Copy Option */}
        {menu.textToCopy && (
          <button
            type="button"
            onClick={handleCopy}
            className="w-full flex items-center justify-between px-3 py-2 rounded-lg hover:bg-zinc-800 text-left transition-colors cursor-pointer group"
          >
            <div className="flex items-center gap-2">
              {copied ? (
                <Check className="w-4 h-4 text-emerald-400" />
              ) : (
                <Copy className="w-4 h-4 text-amber-400 group-hover:scale-110 transition-transform" />
              )}
              <span className={`font-medium ${copied ? 'text-emerald-400 font-semibold' : 'text-zinc-100'}`}>
                {copied ? 'Copied!' : menu.isSelection ? 'Copy Selection' : 'Copy'}
              </span>
            </div>
            <span className="text-[10px] text-zinc-500 font-mono hidden sm:inline">Ctrl+C</span>
          </button>
        )}

        {/* Cut Option (when in editable area with selection) */}
        {menu.isEditable && menu.isSelection && menu.textToCopy && (
          <button
            type="button"
            onClick={handleCut}
            className="w-full flex items-center justify-between px-3 py-2 rounded-lg hover:bg-zinc-800 text-left transition-colors cursor-pointer group"
          >
            <div className="flex items-center gap-2">
              <Scissors className="w-4 h-4 text-indigo-400 group-hover:scale-110 transition-transform" />
              <span className="font-medium text-zinc-100">Cut</span>
            </div>
            <span className="text-[10px] text-zinc-500 font-mono hidden sm:inline">Ctrl+X</span>
          </button>
        )}

        {/* Paste Option (when in editable area) */}
        {menu.isEditable && (
          <button
            type="button"
            onClick={handlePaste}
            className="w-full flex items-center justify-between px-3 py-2 rounded-lg hover:bg-zinc-800 text-left transition-colors cursor-pointer group"
          >
            <div className="flex items-center gap-2">
              <Clipboard className="w-4 h-4 text-emerald-400 group-hover:scale-110 transition-transform" />
              <span className="font-medium text-zinc-100">Paste</span>
            </div>
            <span className="text-[10px] text-zinc-500 font-mono hidden sm:inline">Ctrl+V</span>
          </button>
        )}

        {/* Select All Option */}
        <button
          type="button"
          onClick={handleSelectAll}
          className="w-full flex items-center justify-between px-3 py-2 rounded-lg hover:bg-zinc-800 text-left transition-colors cursor-pointer group border-t border-zinc-800/80 mt-0.5 pt-1.5"
        >
          <div className="flex items-center gap-2">
            <CornerDownLeft className="w-3.5 h-3.5 text-zinc-400 group-hover:text-zinc-200" />
            <span className="text-zinc-300">Select All</span>
          </div>
          <span className="text-[10px] text-zinc-500 font-mono hidden sm:inline">Ctrl+A</span>
        </button>
      </div>
    </div>
  );
};
