import { supabase } from "@/lib/supabase";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Clock, BarChart3, BookOpen } from "lucide-react";
import type { Course } from "@/types/database";

async function getCourse(slug: string): Promise<Course | null> {
  const { data, error } = await supabase
    .from("courses")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error || !data) return null;
  return data;
}

interface Props {
  params: Promise<{ slug: string }>;
}

export default async function CourseDetailPage({ params }: Props) {
  const { slug } = await params;
  const course = await getCourse(slug);

  if (!course) notFound();

  return (
    <div className="container py-12 md:py-16">
      <article className="mx-auto max-w-3xl">
        <Button variant="ghost" size="sm" asChild className="-ml-3 mb-6">
          <Link href="/paths">
            <ArrowLeft className="mr-2 h-4 w-4" />
            返回学习路径
          </Link>
        </Button>

        <header className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            {course.title}
          </h1>
          <p className="mt-3 text-muted-foreground">{course.description}</p>
        </header>

        <div className="prose prose-neutral dark:prose-invert max-w-none">
          {course.content.split('\n').map((line, i) => {
            if (line.startsWith('# ')) return <h1 key={i} className="text-3xl font-bold tracking-tight mt-6 mb-4">{line.slice(2)}</h1>;
            if (line.startsWith('## ')) return <h2 key={i} className="text-2xl font-semibold tracking-tight mt-5 mb-3">{line.slice(3)}</h2>;
            if (line.startsWith('### ')) return <h3 key={i} className="text-xl font-semibold mt-4 mb-2">{line.slice(4)}</h3>;
            if (line.startsWith('#### ')) return <h4 key={i} className="text-lg font-semibold mt-3 mb-2">{line.slice(5)}</h4>;
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
