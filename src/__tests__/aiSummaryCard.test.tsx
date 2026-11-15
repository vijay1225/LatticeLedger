// @vitest-environment jsdom
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, cleanup } from '@testing-library/react';
import { AISummaryCard } from '../components/AISummaryCard';
import { AISummary } from '../types';

afterEach(() => {
  cleanup();
});

describe('AISummaryCard Component', () => {
  const mockSummary: AISummary = {
    tldr: [
      'The Pensieve is an enchanted stone basin used by witches and wizards to review and preserve complex thoughts and memories.',
      'Siphoning a memory with a wand allows third-person immersion into past historical events.'
    ],
    actionItems: [
      'Store memories from the Astronomy Tower confrontation',
      'Consult Dumbledore about the memory siphon charm'
    ],
    tags: ['Pensieve', 'MemoryMagic', 'Hogwarts'],
    keyEntities: ['Albus Dumbledore', 'Harry Potter'],
    generatedAt: Date.now(),
    model: 'gemini-3.8-flash'
  };

  it('renders complete takeaways without truncation classes', () => {
    const { container } = render(
      <AISummaryCard
        summary={mockSummary}
        onRefresh={vi.fn()}
        isLoading={false}
        hasApiKey={true}
      />
    );

    // Verify full takeaway texts are rendered
    expect(screen.getByText(/The Pensieve is an enchanted stone basin/)).toBeDefined();
    expect(screen.getByText(/Siphoning a memory with a wand/)).toBeDefined();

    // Verify line-clamp-1 and truncate are NOT present on takeaway elements
    const clampedElements = container.querySelectorAll('.line-clamp-1, .truncate');
    const takeawayClamps = Array.from(clampedElements).filter(el => 
      el.textContent?.includes('The Pensieve') || el.textContent?.includes('Siphoning a memory')
    );
    expect(takeawayClamps.length).toBe(0);
  });

  it('renders action items when present', () => {
    render(
      <AISummaryCard
        summary={mockSummary}
        onRefresh={vi.fn()}
        isLoading={false}
        hasApiKey={true}
      />
    );

    expect(screen.getByText('Action Items')).toBeDefined();
    expect(screen.getByText(/Store memories from the Astronomy Tower/)).toBeDefined();
    expect(screen.getByText(/Consult Dumbledore about the memory/)).toBeDefined();
  });

  it('renders clickable tags', () => {
    const onTagClick = vi.fn();
    render(
      <AISummaryCard
        summary={mockSummary}
        onRefresh={vi.fn()}
        isLoading={false}
        onTagClick={onTagClick}
        hasApiKey={true}
      />
    );

    const tagBtn = screen.getByText('#Pensieve');
    expect(tagBtn).toBeDefined();
    fireEvent.click(tagBtn);
    expect(onTagClick).toHaveBeenCalledWith('Pensieve');
  });

  it('shows api key required state when hasApiKey is false', () => {
    const onOpenSettings = vi.fn();
    render(
      <AISummaryCard
        onRefresh={vi.fn()}
        isLoading={false}
        hasApiKey={false}
        onOpenSettings={onOpenSettings}
      />
    );

    expect(screen.getByText(/Gemini API Key required/i)).toBeDefined();
    const configBtn = screen.getByText('Configure in Settings');
    fireEvent.click(configBtn);
    expect(onOpenSettings).toHaveBeenCalled();
  });
});
