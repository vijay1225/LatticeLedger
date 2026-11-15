import { Flashcard, FlashcardStage } from '../types';

/**
 * Returns YYYY-MM-DD formatted date string in local timezone.
 */
export function getTodayDateStr(d: Date = new Date()): string {
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Calculates a future YYYY-MM-DD date by adding days to fromDate.
 */
export function calculateNextDate(days: number, fromDate: Date = new Date()): string {
  const d = new Date(fromDate);
  d.setDate(d.getDate() + days);
  return getTodayDateStr(d);
}

/**
 * Creates a brand new Flashcard for a note at Stage 1 (due next day).
 */
export function createNewFlashcard(noteId: string): Flashcard {
  return {
    id: `fc_${noteId}`,
    noteId,
    stage: 1,
    nextReviewDate: calculateNextDate(1),
    createdAt: Date.now(),
    status: 'active'
  };
}

/**
 * Advances a flashcard to the next spaced interval:
 * Stage 1 (Next Day) -> Stage 2 (+7 Days)
 * Stage 2 (+7 Days)  -> Stage 3 (+1 Month / 30 Days)
 * Stage 3 (+1 Month) -> Stage 4 (Mastered Archive)
 */
export function advanceFlashcard(card: Flashcard, reviewDate: Date = new Date()): Flashcard {
  const reviewedAt = reviewDate.getTime();

  if (card.stage === 1) {
    return {
      ...card,
      stage: 2,
      nextReviewDate: calculateNextDate(7, reviewDate),
      lastReviewedAt: reviewedAt,
      status: 'active'
    };
  }

  if (card.stage === 2) {
    return {
      ...card,
      stage: 3,
      nextReviewDate: calculateNextDate(30, reviewDate),
      lastReviewedAt: reviewedAt,
      status: 'active'
    };
  }

  // Stage 3 -> Mastered
  return {
    ...card,
    stage: 4,
    lastReviewedAt: reviewedAt,
    status: 'mastered'
  };
}

/**
 * Resets a mastered or existing flashcard back to Stage 1 (due tomorrow).
 */
export function resetFlashcard(card: Flashcard, fromDate: Date = new Date()): Flashcard {
  return {
    ...card,
    stage: 1,
    nextReviewDate: calculateNextDate(1, fromDate),
    status: 'active'
  };
}

/**
 * Checks whether a flashcard is currently due for review on a given date.
 */
export function isFlashcardDue(card: Flashcard, todayStr?: string): boolean {
  if (card.status === 'mastered' || card.stage === 4) {
    return false;
  }

  const today = todayStr || getTodayDateStr();

  // If card was already reviewed on this exact day, do not show it as due again today
  if (card.lastReviewedAt) {
    const reviewedDay = getTodayDateStr(new Date(card.lastReviewedAt));
    if (reviewedDay === today) {
      return false;
    }
  }

  return card.nextReviewDate <= today;
}

/**
 * Human-readable stage description and interval labels.
 */
export function getStageDescription(stage: FlashcardStage): {
  name: string;
  badge: string;
  interval: string;
  nextInterval: string;
} {
  switch (stage) {
    case 1:
      return {
        name: 'Stage 1',
        badge: '1st Review (Next Day)',
        interval: '1 Day',
        nextInterval: '7 Days'
      };
    case 2:
      return {
        name: 'Stage 2',
        badge: '2nd Review (+7 Days)',
        interval: '7 Days',
        nextInterval: '1 Month'
      };
    case 3:
      return {
        name: 'Stage 3',
        badge: 'Final Review (+1 Month)',
        interval: '30 Days',
        nextInterval: 'Mastered'
      };
    case 4:
    default:
      return {
        name: 'Mastered',
        badge: 'Mastered Archive',
        interval: 'Graduated',
        nextInterval: 'Complete'
      };
  }
}
