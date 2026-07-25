import { supabase } from "@/lib/supabase";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, ExternalLink, Code2, MessageSquare } from "lucide-react";
import type { Project } from "@/types/database";

async function getProject(slug: string): Promise<Project | null> {
  const { data, error } = await supabase
    .from("projects")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error || !data) return null;
  return data;
}

interface Props {
  params: Promise<{ slug: string }>;
}

export default async function ProjectDetailPage({ params }: Props) {
  const { slug } = await params;
  const project = await getProject(slug);

  if (!project) notFound();

  return (
    <div className="container py-12 md:py-16">
      <article className="mx-auto max-w-3xl">
        <Button variant="ghost" size="sm" asChild className="-ml-3 mb-6">
          <Link href="/projects">
            <ArrowLeft className="mr-2 h-4 w-4" />
            返回项目列表
          </Link>
        </Button>

        <header className="mb-8">
          <div className="flex flex-wrap items-center gap-2 mb-3">
            <Badge variant="secondary">{project.difficulty}</Badge>
          </div>
          <h1 className="text-3xl font-bold tracking-tight">{project.title}</h1>
          <p className="mt-2 text-muted-foreground">{project.description}</p>
          <div className="mt-4 flex flex-wrap gap-2">
            {project.tech_stack?.map((tech) => (
              <Badge key={tech} variant="outline">{tech}</Badge>
            ))}
          </div>
          <div className="mt-4 flex items-center gap-3">
            {project.github_url && (
              <Button variant="outline" size="sm" asChild>
                <a href={project.github_url} target="_blank" rel="noopener noreferrer">
                  <Code2 className="mr-2 h-4 w-4" />
                  GitHub
                </a>
              </Button>
            )}
            {project.demo_url && (
              <Button variant="outline" size="sm" asChild>
                <a href={project.demo_url} target="_blank" rel="noopener noreferrer">
                  <ExternalLink className="mr-2 h-4 w-4" />
                  Demo
                </a>
              </Button>
            )}
          </div>
        </header>

        <div className="prose prose-neutral dark:prose-invert max-w-none">
          <div className="rounded-lg border bg-muted/30 p-6">
            <p className="text-muted-foreground text-sm mb-3">
              项目文档将在 Phase 3 完善 MDX 渲染后完整展示。以下是原始内容：
            </p>
            <pre className="whitespace-pre-wrap text-sm text-foreground/80 max-h-[800px] overflow-auto">
              {project.content}
            </pre>
          </div>
        </div>
      </article>
    </div>
  );
}
