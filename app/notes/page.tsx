import { supabase } from "@/lib/supabase";
import { NotesList } from "@/components/notes/notes-list";
import type { Note } from "@/types/database";

async function getNotes(): Promise<Note[]> {
  const { data, error } = await supabase
    .from("notes")
    .select("*")
    .eq("is_published", true)
    .order("updated_at", { ascending: false });

  if (error || !data) {
    return [];
  }
  return data;
}

export default async function NotesPage() {
  const notes = await getNotes();

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl text-center mb-12">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          学习笔记
        </h1>
        <p className="mt-4 text-muted-foreground">
          个人学习心得、代码片段与踩坑记录
        </p>
      </div>

      {notes.length === 0 ? (
        <div className="mx-auto max-w-2xl text-center py-12">
          <p className="text-muted-foreground">
            暂无笔记数据，请先在 Supabase 中配置。
          </p>
        </div>
      ) : (
        <NotesList notes={notes} />
      )}
    </div>
  );
}
