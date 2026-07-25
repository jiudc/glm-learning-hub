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
          {note.content.split('\n').map((line, i) => {
            if (line.startsWith('# ')) return <h1 key={i} className="text-3xl font-bold tracking-tight mt-6 mb-4">{line.slice(2)}</h1>;
            if (line.startsWith('## ')) return <h2 key={i} className="text-2xl font-semibold tracking-tight mt-5 mb-3">{line.slice(3)}</h2>;
            if (line.startsWith('### ')) return <h3 key={i} className="text-xl font-semibold mt-4 mb-2">{line.slice(4)}</h3>;
            if (line.startsWith('- ')) return <li key={i} className="ml-4 text-foreground/80">{line.slice(2)}</li>;
            if (line.startsWith('```')) return <div key={i} className="rounded-lg bg-muted p-4 my-4 font-mono text-sm overflow-x-auto" />;
            if (line.startsWith('| ')) return <p key={i} className="font-mono text-sm">{line}</p>;
            if (line.trim() === '') return <br key={i} />;
            return <p key={i} className="text-foreground/80 leading-relaxed">{line.replace(/\*\*(.*?)\*\*/g, '$1')}</p>;
          })}
        </div>
      </article>
    </div>
  );
}
