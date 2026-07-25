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
          <div className="rounded-lg border bg-muted/30 p-6">
            <p className="text-muted-foreground text-sm mb-3">
              MDX 内容渲染将在后续阶段完善。以下是课程内容：
            </p>
            <pre className="whitespace-pre-wrap text-sm text-foreground/80 max-h-[600px] overflow-auto">
              {course.content}
            </pre>
          </div>
        </div>
      </article>
    </div>
  );
}
