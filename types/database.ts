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
    };
  };
}

// Convenience types
export type LearningPath = Database["public"]["Tables"]["learning_paths"]["Row"];
export type LearningStage = Database["public"]["Tables"]["learning_stages"]["Row"];
export type Resource = Database["public"]["Tables"]["resources"]["Row"];
export type Note = Database["public"]["Tables"]["notes"]["Row"];
export type NoteStage = Database["public"]["Tables"]["note_stages"]["Row"];

// Stage status type
export type StageStatus = "not_started" | "in_progress" | "completed";

// Resource category type
export type ResourceCategory = "docs" | "github" | "tutorial" | "video" | "paper";
