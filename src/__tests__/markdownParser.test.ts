import { describe, it, expect } from 'vitest';
import { convertMarkdownToHtml } from '../utils/markdownParser';

describe('convertMarkdownToHtml', () => {
  it('converts headings, bold, and italics', () => {
    const md = '## My Heading\n\nThis is **bold** and *italic* text.';
    const html = convertMarkdownToHtml(md);
    expect(html).toContain('<h2>My Heading</h2>');
    expect(html).toContain('<strong>bold</strong>');
    expect(html).toContain('<em>italic</em>');
  });

  it('converts standard task lists', () => {
    const md = '- [ ] Todo item\n- [x] Completed item';
    const html = convertMarkdownToHtml(md);
    expect(html).toContain('data-type="taskList"');
    expect(html).toContain('data-type="taskItem" data-checked="false"');
    expect(html).toContain('data-type="taskItem" data-checked="true"');
  });

  it('converts loose checkboxes without dash', () => {
    const md = '[] Buy groceries\n[x] Finished task';
    const html = convertMarkdownToHtml(md);
    expect(html).toContain('data-type="taskList"');
    expect(html).toContain('data-type="taskItem" data-checked="false"');
    expect(html).toContain('data-type="taskItem" data-checked="true"');
    expect(html).toContain('Buy groceries');
  });

  it('converts blockquotes and code fences', () => {
    const md = '> Important note\n\n```typescript\nconst x = 10;\n```';
    const html = convertMarkdownToHtml(md);
    expect(html).toContain('<blockquote>');
    expect(html).toContain('<pre>');
    expect(html).toContain('const x = 10;');
  });
});
