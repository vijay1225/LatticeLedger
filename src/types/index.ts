export type NoteType = 'wiki' | 'quick' | 'journal';

export interface AISummary {
  tldr: string[];
  actionItems: string[];
  tags: string[];
  keyEntities: string[];
  generatedAt: number;
  model: string;
}

export interface Note {
  id: string;
  type: NoteType;
  title: string;
  content: string;
  tags: string[];
  links: string[]; // target titles or IDs linked via [[wiki-links]]
  summary?: AISummary;
  createdAt: number;
  updatedAt: number;
  isPinned?: boolean;
}

export interface KnowledgeGraphNode {
  id: string;
  label: string;
  type: 'wiki' | 'quick' | 'tag' | 'journal';
  noteId?: string;
  size: number;
  color: string;
}

export interface KnowledgeGraphEdge {
  id: string;
  source: string;
  target: string;
  type: 'explicit' | 'semantic'; // explicit = [[wiki-link]], semantic = shared tags
  label?: string;
}

export interface KnowledgeGraphData {
  nodes: KnowledgeGraphNode[];
  edges: KnowledgeGraphEdge[];
}

export interface AIProviderConfig {
  provider: 'gemini' | 'openai' | 'claude' | 'ollama';
  apiKey: string;
  modelName: string;
  baseUrl?: string;
}

export interface GeminiModelInfo {
  id: string;
  name: string;
  displayName: string;
  description?: string;
  isRecommended?: boolean;
}

export type ViewMode = 'journals' | 'pages' | 'notes' | 'quick' | 'flashcards' | 'search' | 'graph' | 'settings';
export type SearchTab = 'instant' | 'ask-ai';
export type AppTheme = 'dark' | 'slate' | 'sepia' | 'light';

export type FlashcardStage = 1 | 2 | 3 | 4; // 1 = Next Day (+1d), 2 = +7d, 3 = +30d, 4 = Mastered

export interface Flashcard {
  id: string; // unique ID
  noteId: string;
  stage: FlashcardStage;
  nextReviewDate: string; // ISO date string "YYYY-MM-DD"
  lastReviewedAt?: number; // timestamp ms
  createdAt: number;
  status: 'active' | 'mastered';
}

export interface ContextualSuggestion {
  quickNote: Note;
  matchedTags: string[];
  reason: string;
}
