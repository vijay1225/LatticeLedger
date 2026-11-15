import { describe, it, expect } from 'vitest';
import {
  calculateNextDate,
  createNewFlashcard,
  advanceFlashcard,
  resetFlashcard,
  isFlashcardDue,
  getStageDescription
} from '../services/flashcardService';

describe('Flashcard & Spaced Repetition Service', () => {
  it('creates a new flashcard at Stage 1 due the next day (+1 day)', () => {
    const card = createNewFlashcard('note-123');
    expect(card.noteId).toBe('note-123');
    expect(card.stage).toBe(1);
    expect(card.status).toBe('active');
    expect(card.nextReviewDate).toBe(calculateNextDate(1));
  });

  it('advances Stage 1 to Stage 2 due in +7 days', () => {
    const baseDate = new Date('2026-11-15T10:00:00Z');
    const card = createNewFlashcard('note-123');
    const advanced = advanceFlashcard(card, baseDate);

    expect(advanced.stage).toBe(2);
    expect(advanced.status).toBe('active');
    expect(advanced.nextReviewDate).toBe('2026-11-22'); // 15 + 7
    expect(advanced.lastReviewedAt).toBe(baseDate.getTime());
  });

  it('advances Stage 2 to Stage 3 due in +30 days (1 month)', () => {
    const baseDate = new Date('2026-11-22T10:00:00Z');
    const card = {
      id: 'fc_note-123',
      noteId: 'note-123',
      stage: 2 as const,
      nextReviewDate: '2026-11-22',
      createdAt: Date.now(),
      status: 'active' as const
    };
    const advanced = advanceFlashcard(card, baseDate);

    expect(advanced.stage).toBe(3);
    expect(advanced.status).toBe('active');
    expect(advanced.nextReviewDate).toBe('2026-12-22'); // 22 + 30 days
  });

  it('advances Stage 3 to Stage 4 (Mastered Archive)', () => {
    const baseDate = new Date('2026-12-22T10:00:00Z');
    const card = {
      id: 'fc_note-123',
      noteId: 'note-123',
      stage: 3 as const,
      nextReviewDate: '2026-12-22',
      createdAt: Date.now(),
      status: 'active' as const
    };
    const advanced = advanceFlashcard(card, baseDate);

    expect(advanced.stage).toBe(4);
    expect(advanced.status).toBe('mastered');
  });

  it('resets a mastered flashcard back to Stage 1 due tomorrow', () => {
    const card = {
      id: 'fc_note-123',
      noteId: 'note-123',
      stage: 4 as const,
      nextReviewDate: '2026-12-22',
      createdAt: Date.now(),
      status: 'mastered' as const
    };
    const reset = resetFlashcard(card, new Date('2027-01-01T00:00:00Z'));

    expect(reset.stage).toBe(1);
    expect(reset.status).toBe('active');
    expect(reset.nextReviewDate).toBe('2027-01-02');
  });

  it('correctly calculates if a flashcard is due', () => {
    const today = '2026-11-15';

    // Due in the past or today -> DUE
    const dueCard = {
      id: 'fc_1',
      noteId: 'note-1',
      stage: 1 as const,
      nextReviewDate: '2026-11-15',
      createdAt: Date.now(),
      status: 'active' as const
    };
    expect(isFlashcardDue(dueCard, today)).toBe(true);

    // Due in the future -> NOT DUE
    const futureCard = {
      id: 'fc_2',
      noteId: 'note-2',
      stage: 2 as const,
      nextReviewDate: '2026-11-20',
      createdAt: Date.now(),
      status: 'active' as const
    };
    expect(isFlashcardDue(futureCard, today)).toBe(false);

    // Mastered -> NEVER DUE
    const masteredCard = {
      id: 'fc_3',
      noteId: 'note-3',
      stage: 4 as const,
      nextReviewDate: '2026-11-01',
      createdAt: Date.now(),
      status: 'mastered' as const
    };
    expect(isFlashcardDue(masteredCard, today)).toBe(false);

    // Card reviewed today already -> NOT DUE today
    const reviewedTodayCard = {
      id: 'fc_4',
      noteId: 'note-4',
      stage: 2 as const,
      nextReviewDate: '2026-11-15',
      lastReviewedAt: new Date('2026-11-15T08:00:00').getTime(),
      createdAt: Date.now(),
      status: 'active' as const
    };
    expect(isFlashcardDue(reviewedTodayCard, today)).toBe(false);
  });

  it('provides descriptive stage metadata', () => {
    expect(getStageDescription(1).interval).toBe('1 Day');
    expect(getStageDescription(2).interval).toBe('7 Days');
    expect(getStageDescription(3).interval).toBe('30 Days');
    expect(getStageDescription(4).interval).toBe('Graduated');
  });
});
