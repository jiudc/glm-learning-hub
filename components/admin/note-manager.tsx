"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { supabase } from "@/lib/supabase";
import {
  Trash2,
  Eye,
  EyeOff,
  Loader2,
  FileText,
} from "lucide-react";
import type { Note } from "@/types/database";

interface Props {
  notes: Note[];
}

export function NoteManager({ notes }: Props) {
  const router = useRouter();
  const [deleting, setDeleting] = useState<string | null>(null);
  const [toggling, setToggling] = useState<string | null>(null);

  const handleDelete = async (id: string, title: string) => {
    if (!confirm(`确定要删除笔记「${title}」吗？`)) return;

    setDeleting(id);
    try {
      const { error } = await supabase.from("notes").delete().eq("id", id);
      if (error) throw error;
      router.refresh();
    } catch (err) {
      alert("删除失败: " + (err as Error).message);
    } finally {
      setDeleting(null);
    }
  };

  const handleTogglePublish = async (
    id: string,
    currentStatus: boolean
  ) => {
    setToggling(id);
    try {
      const { error } = await supabase
        .from("notes")
        .update({ is_published: !currentStatus, updated_at: new Date().toISOString() })
        .eq("id", id);
      if (error) throw error;
      router.refresh();
    } catch (err) {
      alert("操作失败: " + (err as Error).message);
    } finally {
      setToggling(null);
    }
  };

  if (notes.length === 0) {
    return (
      <div className="text-center py-8 text-muted-foreground">
        <FileText className="mx-auto h-12 w-12 mb-3 opacity-50" />
        <p>暂无笔记，请在左侧创建</p>
      </div>
    );
  }

  return (
    <div className="space-y-3 max-h-[600px] overflow-y-auto pr-2">
      {notes.map((note) => (
        <div
          key={note.id}
          className="rounded-lg border p-3 hover:bg-muted/50 transition-colors"
        >
          <div className="flex items-start justify-between gap-2">
            <div className="min-w-0 flex-1">
              <h3 className="font-medium text-sm truncate">{note.title}</h3>
              <div className="mt-1 flex items-center gap-2">
                {note.category && (
                  <Badge variant="secondary" className="text-xs">
                    {note.category}
                  </Badge>
                )}
                <Badge
                  variant={note.is_published ? "default" : "outline"}
                  className="text-xs"
                >
                  {note.is_published ? "已发布" : "草稿"}
                </Badge>
              </div>
            </div>
            <div className="flex items-center gap-1 shrink-0">
              <Button
                variant="ghost"
                size="icon"
                className="h-7 w-7"
                onClick={() => handleTogglePublish(note.id, note.is_published)}
                disabled={toggling === note.id}
                title={note.is_published ? "设为草稿" : "发布"}
              >
                {toggling === note.id ? (
                  <Loader2 className="h-3 w-3 animate-spin" />
                ) : note.is_published ? (
                  <EyeOff className="h-3 w-3" />
                ) : (
                  <Eye className="h-3 w-3" />
                )}
              </Button>
              <Button
                variant="ghost"
                size="icon"
                className="h-7 w-7 text-destructive hover:text-destructive"
                onClick={() => handleDelete(note.id, note.title)}
                disabled={deleting === note.id}
                title="删除"
              >
                {deleting === note.id ? (
                  <Loader2 className="h-3 w-3 animate-spin" />
                ) : (
                  <Trash2 className="h-3 w-3" />
                )}
              </Button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
