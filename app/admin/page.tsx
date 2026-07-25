import { supabase } from "@/lib/supabase";
import { NoteForm } from "@/components/admin/note-form";
import { NoteManager } from "@/components/admin/note-manager";
import type { Note } from "@/types/database";

async function getNotes(): Promise<Note[]> {
  const { data, error } = await supabase
    .from("notes")
    .select("*")
    .order("updated_at", { ascending: false });

  if (error || !data) {
    return [];
  }
  return data;
}

export default async function AdminPage() {
  const notes = await getNotes();

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-4xl">
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight">管理后台</h1>
          <p className="mt-2 text-muted-foreground">
            管理学习笔记 — 创建、编辑、删除
          </p>
        </div>

        <div className="grid gap-8 lg:grid-cols-2">
          {/* Create / Edit Form */}
          <div>
            <h2 className="text-lg font-semibold mb-4">新建笔记</h2>
            <NoteForm />
          </div>

          {/* Notes List */}
          <div>
            <h2 className="text-lg font-semibold mb-4">
              已有笔记 ({notes.length})
            </h2>
            <NoteManager notes={notes} />
          </div>
        </div>
      </div>
    </div>
  );
}
