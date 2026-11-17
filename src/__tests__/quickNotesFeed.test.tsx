// @vitest-environment jsdom
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, cleanup } from '@testing-library/react';
import { QuickNotesFeed } from '../components/QuickNotesFeed';
import { Note } from '../types';

afterEach(() => {
  cleanup();
});

describe('QuickNotesFeed Target Note Navigation', () => {
  const mockQuickNotes: Note[] = [
    {
      id: 'quick-1',
      type: 'quick',
      title: 'Quick note: First idea',
      content: 'First idea about spells',
      tags: ['#magic'],
      links: [],
      createdAt: 1000,
      updatedAt: 1000
    },
    {
      id: 'quick-2',
      type: 'quick',
      title: 'Quick note: Target secret note',
      content: 'Secret potion recipe for polyjuice',
      tags: ['#potions'],
      links: [],
      createdAt: 2000,
      updatedAt: 2000
    },
    {
      id: 'quick-3',
      type: 'quick',
      title: 'Quick note: Third idea',
      content: 'Third idea about broomsticks',
      tags: ['#flying'],
      links: [],
      createdAt: 3000,
      updatedAt: 3000
    }
  ];

  it('renders normal feed without banner when activeNoteId is not provided', () => {
    render(
      <QuickNotesFeed
        quickNotes={mockQuickNotes}
        onAddQuickNote={vi.fn()}
        onDeleteQuickNote={vi.fn()}
        onPromoteToWiki={vi.fn()}
      />
    );

    expect(screen.queryByText(/Navigated to Quick Note/i)).toBeNull();
    expect(screen.queryByText(/Target Note/i)).toBeNull();
    expect(screen.getByText('First idea about spells')).toBeDefined();
    expect(screen.getByText('Secret potion recipe for polyjuice')).toBeDefined();
  });

  it('renders target note banner and highlights targeted note when activeNoteId is set', () => {
    render(
      <QuickNotesFeed
        quickNotes={mockQuickNotes}
        activeNoteId="quick-2"
        onClearActiveNote={vi.fn()}
        onAddQuickNote={vi.fn()}
        onDeleteQuickNote={vi.fn()}
        onPromoteToWiki={vi.fn()}
      />
    );

    // Should display top navigation banner
    expect(screen.getByText(/Navigated to Quick Note/i)).toBeDefined();
    expect(screen.getAllByText(/Secret potion recipe/i).length).toBeGreaterThanOrEqual(2);

    // Should display target badge
    expect(screen.getByText(/Target Note/i)).toBeDefined();

    // Target card element should have ring highlight class
    const targetCard = document.getElementById('quick-note-quick-2');
    expect(targetCard).toBeDefined();
    expect(targetCard?.className).toContain('ring-2 ring-amber-400');
  });

  it('calls onClearActiveNote when Show All button is clicked', () => {
    const handleClear = vi.fn();
    render(
      <QuickNotesFeed
        quickNotes={mockQuickNotes}
        activeNoteId="quick-2"
        onClearActiveNote={handleClear}
        onAddQuickNote={vi.fn()}
        onDeleteQuickNote={vi.fn()}
        onPromoteToWiki={vi.fn()}
      />
    );

    const showAllBtn = screen.getByTitle('View all quick notes without filter');
    fireEvent.click(showAllBtn);
    expect(handleClear).toHaveBeenCalledTimes(1);
  });
});
