import { supabase } from "@/lib/supabase";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { ArrowRight, ExternalLink } from "lucide-react";
import type { Project } from "@/types/database";

async function getProjects(): Promise<Project[]> {
  const { data, error } = await supabase
    .from("projects")
    .select("*")
    .order("sort_order");

  if (error || !data) return [];
  return data;
}

const difficultyConfig: Record<string, { label: string; color: string }> = {
  beginner: { label: "入门", color: "bg-green-100 text-green-700 dark:bg-green-900/30" },
  intermediate: { label: "中级", color: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30" },
  advanced: { label: "高级", color: "bg-red-100 text-red-700 dark:bg-red-900/30" },
};

export default async function ProjectsPage() {
  const projects = await getProjects();

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl text-center mb-10">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          项目作品集
        </h1>
        <p className="mt-3 text-muted-foreground">
          5 个梯度项目，每个含技术栈、架构图、代码、面试话术
        </p>
      </div>

      {projects.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground">
          <p>暂无项目数据，请先在 Supabase 中执行 seed_v2.sql</p>
        </div>
      ) : (
        <div className="mx-auto max-w-5xl space-y-6">
          {projects.map((project) => (
            <Card key={project.id} className="transition-shadow hover:shadow-md">
              <CardHeader>
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <Link href={`/projects/${project.slug}`}>
                      <CardTitle className="text-xl hover:text-blue-600 transition-colors">
                        {project.title}
                      </CardTitle>
                    </Link>
                    <CardDescription className="mt-1">
                      {project.description}
                    </CardDescription>
                  </div>
                  <Badge className={difficultyConfig[project.difficulty]?.color || ""}>
                    {difficultyConfig[project.difficulty]?.label || project.difficulty}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex flex-wrap gap-2 mb-3">
                  {project.tech_stack?.map((tech) => (
                    <Badge key={tech} variant="outline" className="text-xs">
                      {tech}
                    </Badge>
                  ))}
                </div>
                <div className="flex items-center gap-3">
                  <Button variant="ghost" size="sm" asChild>
                    <Link href={`/projects/${project.slug}`}>
                      查看详情
                      <ArrowRight className="ml-1 h-3 w-3" />
                    </Link>
                  </Button>
                  {project.github_url && (
                    <Button variant="ghost" size="sm" asChild>
                      <a href={project.github_url} target="_blank" rel="noopener noreferrer">
                        GitHub
                        <ExternalLink className="ml-1 h-3 w-3" />
                      </a>
                    </Button>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
