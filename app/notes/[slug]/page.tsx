import { supabase } from "@/lib/supabase";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Calendar, Tag } from "lucide-react";
import type { Note } from "@/types/database";

async function getNote(slug: string): Promise<Note | null> {
  const { data, error } = await supabase
    .from("notes")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error || !data) {
    return null;
  }
  return data;
}

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString("zh-CN", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

interface Props {
  params: Promise<{ slug: string }>;
}

export default async function NoteDetailPage({ params }: Props) {
  const { slug } = await params;
  const note = await getNote(slug);

  if (!note) {
    notFound();
  }

  return (
    <div className="container py-12 md:py-16">
      <article className="mx-auto max-w-3xl">
        {/* Back button */}
        <Button variant="ghost" size="sm" asChild className="-ml-3 mb-6">
          <Link href="/notes">
            <ArrowLeft className="mr-2 h-4 w-4" />
            返回笔记列表
          </Link>
        </Button>

        {/* Header */}
        <header className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            {note.title}
          </h1>
          <div className="mt-4 flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
            <div className="flex items-center gap-1">
              <Calendar className="h-4 w-4" />
              更新于 {formatDate(note.updated_at)}
            </div>
            {note.category && (
              <Badge variant="secondary">{note.category}</Badge>
            )}
          </div>
          {note.tags && note.tags.length > 0 && (
            <div className="mt-3 flex flex-wrap gap-2">
              {note.tags.map((tag) => (
                <Badge key={tag} variant="outline" className="text-xs">
                  <Tag className="mr-1 h-3 w-3" />
                  {tag}
                </Badge>
              ))}
            </div>
          )}
        </header>

        {/* Content */}
        <div className="prose prose-neutral dark:prose-invert max-w-none">
          {/* Note: MDX rendering will be implemented in Phase 3-4 */}
          <div className="rounded-lg border bg-muted/30 p-6">
            <p className="text-muted-foreground mb-4">
              MDX 内容渲染将在后续阶段完善。以下是原始内容预览：
            </p>
            <pre className="whitespace-pre-wrap text-sm text-foreground/80 max-h-96 overflow-auto">
              {note.content}
            </pre>
          </div>
        </div>
      </article>
    </div>
  );
}
