/**
 * @vitest-environment jsdom
 */
import { describe, it, expect, vi } from 'vitest';
import { render } from '@testing-library/react';
import { NoteEditor } from '../components/NoteEditor';
import { JournalsView } from '../components/JournalsView';
import { Note } from '../types';

describe('NoteEditor paste markdown test', () => {
  it('converts pasted markdown to rich text in NoteEditor', () => {
    const dummyNote: Note = {
      id: 'test-1',
      title: 'Test Note',
      content: '',
      type: 'wiki',
      tags: [],
      links: [],
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };

    const { container } = render(
      <NoteEditor
        note={dummyNote}
        allNotes={[dummyNote]}
        onUpdateNote={vi.fn()}
        onRefreshSummary={vi.fn()}
        isSummaryLoading={false}
        onNavigateToNote={vi.fn()}
      />
    );

    const editorEl = container.querySelector('.tiptap.ProseMirror');
    expect(editorEl).toBeTruthy();

    const markdownText = '## Section One\n\nThis is **bold** text and *italic*.\n\n- [ ] Check item 1\n[] Loose check item 2\n- Normal bullet';

    const pasteEvent = new Event('paste', { bubbles: true, cancelable: true });
    Object.defineProperty(pasteEvent, 'clipboardData', {
      value: {
        items: [],
        getData: (format: string) => (format === 'text/plain' ? markdownText : ''),
      },
    });

    editorEl?.dispatchEvent(pasteEvent);

    expect(editorEl?.innerHTML).toContain('<h2>Section One</h2>');
    expect(editorEl?.innerHTML).toContain('<strong>bold</strong>');
    expect(editorEl?.innerHTML).toContain('data-type="taskList"');
    expect(editorEl?.innerHTML).toContain('Check item 1');
    expect(editorEl?.innerHTML).toContain('Loose check item 2');
  });

  it('converts pasted markdown to rich text in JournalsView', () => {
    const { container } = render(
      <JournalsView
        notes={[]}
        onSaveJournal={vi.fn()}
        onDeleteJournal={vi.fn()}
        onNavigateToNote={vi.fn()}
      />
    );

    const editorEl = container.querySelector('.tiptap.ProseMirror');
    expect(editorEl).toBeTruthy();

    const markdownText = '### Daily Tasks\n\n- [ ] Task 1\n[x] Completed task\n\n> Don\'t forget meeting';

    const pasteEvent = new Event('paste', { bubbles: true, cancelable: true });
    Object.defineProperty(pasteEvent, 'clipboardData', {
      value: {
        items: [],
        getData: (format: string) => (format === 'text/plain' ? markdownText : ''),
      },
    });

    editorEl?.dispatchEvent(pasteEvent);

    expect(editorEl?.innerHTML).toContain('<h3>Daily Tasks</h3>');
    expect(editorEl?.innerHTML).toContain('data-type="taskList"');
    expect(editorEl?.innerHTML).toContain('Task 1');
    expect(editorEl?.innerHTML).toContain('Completed task');
    expect(editorEl?.innerHTML).toContain('<blockquote>');
  });
});
