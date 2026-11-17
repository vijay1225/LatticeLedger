// @vitest-environment jsdom
import { describe, it, expect, vi, afterEach, beforeEach } from 'vitest';
import { render, screen, fireEvent, cleanup, act } from '@testing-library/react';
import { AppContextMenu } from '../components/AppContextMenu';

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

describe('AppContextMenu Component', () => {
  beforeEach(() => {
    Object.assign(navigator, {
      clipboard: {
        writeText: vi.fn().mockResolvedValue(undefined),
        readText: vi.fn().mockResolvedValue('pasted clipboard content')
      }
    });
  });

  it('renders nothing by default when no contextmenu or long-press occurs', () => {
    render(<AppContextMenu />);
    expect(screen.queryByText(/Copy/i)).toBeNull();
  });

  it('shows Copy option on right-click contextmenu event when text is present', () => {
    render(
      <div>
        <p data-testid="target-text">Secret potion formula</p>
        <AppContextMenu />
      </div>
    );

    const target = screen.getByTestId('target-text');

    fireEvent.contextMenu(target, {
      clientX: 150,
      clientY: 200
    });

    // Expect menu with Copy option
    const copyBtn = screen.getByRole('button', { name: /Copy/i });
    expect(copyBtn).toBeDefined();

    // Click Copy
    fireEvent.click(copyBtn);
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('Secret potion formula');
  });

  it('shows Copy option on touch long-press (450ms) on mobile', () => {
    vi.useFakeTimers();

    render(
      <div>
        <div data-testid="mobile-card" className="quick-note-card">
          <p>Fleeting mobile thought about spells</p>
        </div>
        <AppContextMenu />
      </div>
    );

    const card = screen.getByTestId('mobile-card');

    // Simulate touchstart
    fireEvent.touchStart(card, {
      touches: [{ clientX: 100, clientY: 150 }]
    });

    // Advance time past 420ms long-press threshold
    act(() => {
      vi.advanceTimersByTime(500);
    });

    const copyBtn = screen.getByRole('button', { name: /Copy/i });
    expect(copyBtn).toBeDefined();

    fireEvent.click(copyBtn);
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('Fleeting mobile thought about spells');

    vi.useRealTimers();
  });
});
