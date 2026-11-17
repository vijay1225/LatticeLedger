import MarkdownIt from 'markdown-it';
// @ts-expect-error - markdown-it-task-lists lacks official TS declarations
import taskLists from 'markdown-it-task-lists';

/**
 * Shared MarkdownIt instance configured for TipTap WYSIWYG compatibility.
 */
const md = new MarkdownIt({
  html: true,
  linkify: true,
  breaks: true,
  typographer: false,
}).use(taskLists, { enabled: true });

/**
 * Normalizes common loose markdown patterns before parsing:
 * 1. Standalone checkboxes like `[] Task` or `[ ] Task` -> `- [ ] Task`
 * 2. Standalone checked checkboxes like `[x] Task` or `[X] Task` -> `- [x] Task`
 */
function normalizeMarkdownForTipTap(content: string): string {
  if (!content) return '';

  return content
    // Normalize loose checkboxes without bullet prefix: `[] item` or `[ ] item` -> `- [ ] item`
    .replace(/^(\s*)\[\s*\]\s+(\S)/gm, '$1- [ ] $2')
    .replace(/^(\s*)\[[xX]\]\s+(\S)/gm, '$1- [x] $2');
}

/**
 * Converts a raw Markdown string into HTML formatted for TipTap nodes:
 * - Headings: <h1>, <h2>, <h3>
 * - Task Lists: <ul data-type="taskList"><li data-type="taskItem" data-checked="false|true">
 * - Bullet / Numbered Lists: <ul>, <ol>
 * - Bold / Italic: <strong>, <em>
 * - Code blocks: <pre><code>
 * - Blockquotes: <blockquote>
 * - Tables, links, horizontal rules
 */
export function convertMarkdownToHtml(markdown: string): string {
  if (!markdown || typeof markdown !== 'string') return '';

  const normalized = normalizeMarkdownForTipTap(markdown);
  let html = md.render(normalized);

  // TipTap TaskList extension expects:
  // <ul data-type="taskList">
  //   <li data-type="taskItem" data-checked="false">...</li>
  // </ul>
  // markdown-it-task-lists produces:
  // <ul class="contains-task-list">
  //   <li class="task-list-item enabled"><input ... checked ...> text</li>
  // </ul>
  html = html
    .replace(/<ul class="contains-task-list">/g, '<ul data-type="taskList">')
    .replace(/<li class="task-list-item[^"]*">\s*<input[^>]*checked[^>]*>\s*([\s\S]*?)<\/li>/gi, '<li data-type="taskItem" data-checked="true"><p>$1</p></li>')
    .replace(/<li class="task-list-item[^"]*">\s*<input[^>]*>\s*([\s\S]*?)<\/li>/gi, '<li data-type="taskItem" data-checked="false"><p>$1</p></li>');

  return html;
}
