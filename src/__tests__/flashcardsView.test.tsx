// @vitest-environment jsdom
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, cleanup } from '@testing-library/react';
import { FlashcardsView } from '../components/FlashcardsView';
import { Note, Flashcard } from '../types';

afterEach(() => {
  cleanup();
});

describe('FlashcardsView Component', () => {
  const mockNotes: Note[] = [
    {
      id: 'note-1',
      type: 'wiki',
      title: 'Quantum Physics Fundamentals',
      content: 'Wave-particle duality and Schrödinger equation.',
      tags: ['#Physics'],
      links: [],
      createdAt: 1000,
      updatedAt: 1000
    },
    {
      id: 'note-2',
      type: 'quick',
      title: 'Quick Thought',
      content: 'Remember to check the research paper on neural lattices.',
      tags: ['#Idea'],
      links: [],
      createdAt: 2000,
      updatedAt: 2000
    }
  ];

  it('renders all caught up state when there are no due flashcards', () => {
    const flashcards: Flashcard[] = [
      {
        id: 'fc_1',
        noteId: 'note-1',
        stage: 2,
        nextReviewDate: '2099-01-01', // future
        createdAt: 1000,
        status: 'active'
      }
    ];

    render(
      <FlashcardsView
        flashcards={flashcards}
        notes={mockNotes}
        onUpdateFlashcard={vi.fn()}
        onRemoveFlashcard={vi.fn()}
        onOpenNote={vi.fn()}
      />
    );

    expect(screen.getByText(/You're all caught up for today!/i)).toBeDefined();
  });

  it('renders due flashcards and calls onUpdateFlashcard when Mark as Reviewed is clicked', () => {
    const onUpdateFlashcard = vi.fn();
    const flashcards: Flashcard[] = [
      {
        id: 'fc_1',
        noteId: 'note-1',
        stage: 1,
        nextReviewDate: '2020-01-01', // due in the past
        createdAt: 1000,
        status: 'active'
      }
    ];

    render(
      <FlashcardsView
        flashcards={flashcards}
        notes={mockNotes}
        onUpdateFlashcard={onUpdateFlashcard}
        onRemoveFlashcard={vi.fn()}
        onOpenNote={vi.fn()}
      />
    );

    expect(screen.getByText('Quantum Physics Fundamentals')).toBeDefined();
    expect(screen.getByText(/Wave-particle duality/i)).toBeDefined();

    const reviewBtn = screen.getByText(/Mark as Reviewed/i);
    fireEvent.click(reviewBtn);

    expect(onUpdateFlashcard).toHaveBeenCalledTimes(1);
    const updated = onUpdateFlashcard.mock.calls[0][0] as Flashcard;
    expect(updated.stage).toBe(2); // Advanced from 1 to 2
    expect(updated.status).toBe('active');
  });

  it('switches to All Cards tab and lists cards and mastered archive', () => {
    const flashcards: Flashcard[] = [
      {
        id: 'fc_1',
        noteId: 'note-1',
        stage: 4,
        nextReviewDate: '2026-11-01',
        createdAt: 1000,
        status: 'mastered'
      }
    ];

    render(
      <FlashcardsView
        flashcards={flashcards}
        notes={mockNotes}
        onUpdateFlashcard={vi.fn()}
        onRemoveFlashcard={vi.fn()}
        onOpenNote={vi.fn()}
      />
    );

    const allTabBtn = screen.getByText('All Cards');
    fireEvent.click(allTabBtn);

    expect(screen.getByText(/Mastered Archive/i)).toBeDefined();
    expect(screen.getByText('Quantum Physics Fundamentals')).toBeDefined();
  });
});
