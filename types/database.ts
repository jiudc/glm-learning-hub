export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export interface Database {
  public: {
    Tables: {
      learning_paths: {
        Row: {
          id: string;
          title: string;
          description: string | null;
          icon: string | null;
          sort_order: number;
          created_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          description?: string | null;
          icon?: string | null;
          sort_order?: number;
          created_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          description?: string | null;
          icon?: string | null;
          sort_order?: number;
          created_at?: string;
        };
      };
      learning_stages: {
        Row: {
          id: string;
          path_id: string;
          title: string;
          description: string | null;
          sort_order: number;
          status: "not_started" | "in_progress" | "completed";
          created_at: string;
        };
        Insert: {
          id?: string;
          path_id: string;
          title: string;
          description?: string | null;
          sort_order?: number;
          status?: "not_started" | "in_progress" | "completed";
          created_at?: string;
        };
        Update: {
          id?: string;
          path_id?: string;
          title?: string;
          description?: string | null;
          sort_order?: number;
          status?: "not_started" | "in_progress" | "completed";
          created_at?: string;
        };
      };
      resources: {
        Row: {
          id: string;
          title: string;
          url: string;
          description: string | null;
          category: string | null;
          tags: string[] | null;
          is_featured: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          url: string;
          description?: string | null;
          category?: string | null;
          tags?: string[] | null;
          is_featured?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          url?: string;
          description?: string | null;
          category?: string | null;
          tags?: string[] | null;
          is_featured?: boolean;
          created_at?: string;
        };
      };
      notes: {
        Row: {
          id: string;
          slug: string;
          title: string;
          content: string;
          excerpt: string | null;
          tags: string[] | null;
          category: string | null;
          is_published: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          slug: string;
          title: string;
          content: string;
          excerpt?: string | null;
          tags?: string[] | null;
          category?: string | null;
          is_published?: boolean;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          slug?: string;
          title?: string;
          content?: string;
          excerpt?: string | null;
          tags?: string[] | null;
          category?: string | null;
          is_published?: boolean;
          created_at?: string;
          updated_at?: string;
        };
      };
      note_stages: {
        Row: {
          note_id: string;
          stage_id: string;
        };
        Insert: {
          note_id: string;
          stage_id: string;
        };
        Update: {
          note_id?: string;
          stage_id?: string;
        };
      };
      courses: {
        Row: {
          id: string;
          path_id: string;
          slug: string;
          title: string;
          description: string | null;
          content: string;
          code_examples: Json;
          video_url: string | null;
          sort_order: number;
          created_at: string;
          updated_at: string;
        };
        Insert: { id?: string; path_id: string; slug: string; title: string; description?: string | null; content?: string; code_examples?: Json; video_url?: string | null; sort_order?: number; created_at?: string; updated_at?: string };
        Update: { id?: string; path_id?: string; slug?: string; title?: string; description?: string | null; content?: string; code_examples?: Json; video_url?: string | null; sort_order?: number; created_at?: string; updated_at?: string };
      };
      labs: {
        Row: {
          id: string;
          course_id: string;
          title: string;
          description: string | null;
          difficulty: string | null;
          estimated_minutes: number;
          starter_code: string;
          solution_code: string;
          environment: Json;
          sort_order: number;
          created_at: string;
        };
        Insert: { id?: string; course_id: string; title: string; description?: string | null; difficulty?: string | null; estimated_minutes?: number; starter_code?: string; solution_code?: string; environment?: Json; sort_order?: number; created_at?: string };
        Update: { id?: string; course_id?: string; title?: string; description?: string | null; difficulty?: string | null; estimated_minutes?: number; starter_code?: string; solution_code?: string; environment?: Json; sort_order?: number; created_at?: string };
      };
      interview_questions: {
        Row: {
          id: string;
          category: string;
          subcategory: string | null;
          question: string;
          hint: string | null;
          answer: string | null;
          difficulty: string;
          company_tag: string[] | null;
          is_featured: boolean;
          sort_order: number;
          created_at: string;
        };
        Insert: { id?: string; category: string; subcategory?: string | null; question: string; hint?: string | null; answer?: string | null; difficulty: string; company_tag?: string[] | null; is_featured?: boolean; sort_order?: number; created_at?: string };
        Update: { id?: string; category?: string; subcategory?: string | null; question?: string; hint?: string | null; answer?: string | null; difficulty?: string; company_tag?: string[] | null; is_featured?: boolean; sort_order?: number; created_at?: string };
      };
      projects: {
        Row: {
          id: string;
          slug: string;
          title: string;
          description: string | null;
          content: string;
          tech_stack: string[] | null;
          github_url: string | null;
          demo_url: string | null;
          difficulty: string;
          is_featured: boolean;
          sort_order: number;
          created_at: string;
        };
        Insert: { id?: string; slug: string; title: string; description?: string | null; content?: string; tech_stack?: string[] | null; github_url?: string | null; demo_url?: string | null; difficulty: string; is_featured?: boolean; sort_order?: number; created_at?: string };
        Update: { id?: string; slug?: string; title?: string; description?: string | null; content?: string; tech_stack?: string[] | null; github_url?: string | null; demo_url?: string | null; difficulty?: string; is_featured?: boolean; sort_order?: number; created_at?: string };
      };
      evaluation_metrics: {
        Row: {
          id: string;
          name: string;
          description: string | null;
          category: string | null;
          formula: string | null;
          tool: string | null;
          use_case: string | null;
          created_at: string;
        };
        Insert: { id?: string; name: string; description?: string | null; category?: string | null; formula?: string | null; tool?: string | null; use_case?: string | null; created_at?: string };
        Update: { id?: string; name?: string; description?: string | null; category?: string | null; formula?: string | null; tool?: string | null; use_case?: string | null; created_at?: string };
      };
    };
  };
}

// Convenience types
export type LearningPath = Database["public"]["Tables"]["learning_paths"]["Row"];
export type LearningStage = Database["public"]["Tables"]["learning_stages"]["Row"];
export type Resource = Database["public"]["Tables"]["resources"]["Row"];
export type Note = Database["public"]["Tables"]["notes"]["Row"];
export type NoteStage = Database["public"]["Tables"]["note_stages"]["Row"];
export type Course = Database["public"]["Tables"]["courses"]["Row"];
export type Lab = Database["public"]["Tables"]["labs"]["Row"];
export type InterviewQuestion = Database["public"]["Tables"]["interview_questions"]["Row"];
export type Project = Database["public"]["Tables"]["projects"]["Row"];
export type EvaluationMetric = Database["public"]["Tables"]["evaluation_metrics"]["Row"];

// Stage status type
export type StageStatus = "not_started" | "in_progress" | "completed";

// Resource category type
export type ResourceCategory = "docs" | "github" | "tutorial" | "video" | "paper";
