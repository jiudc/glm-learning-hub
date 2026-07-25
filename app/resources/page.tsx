import { supabase } from "@/lib/supabase";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ExternalLink, BookOpen, Code2, GraduationCap, Video, FileText } from "lucide-react";
import type { Resource, ResourceCategory } from "@/types/database";

async function getResources(): Promise<Resource[]> {
  const { data, error } = await supabase
    .from("resources")
    .select("*")
    .order("category")
    .order("created_at", { ascending: false });

  if (error || !data) {
    return [];
  }
  return data;
}

const categoryConfig: Record<
  ResourceCategory,
  { label: string; icon: typeof BookOpen; color: string }
> = {
  docs: { label: "官方文档", icon: BookOpen, color: "text-blue-600" },
  github: { label: "GitHub", icon: Code2, color: "text-gray-600" },
  tutorial: { label: "教程", icon: GraduationCap, color: "text-green-600" },
  video: { label: "视频", icon: Video, color: "text-red-600" },
  paper: { label: "论文", icon: FileText, color: "text-purple-600" },
};

export default async function ResourcesPage() {
  const resources = await ResourcesPage_getResources();

  // Group by category
  const grouped = resources.reduce(
    (acc, resource) => {
      const cat = (resource.category || "docs") as ResourceCategory;
      if (!acc[cat]) acc[cat] = [];
      acc[cat].push(resource);
      return acc;
    },
    {} as Record<string, Resource[]>
  );

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl text-center mb-12">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          资源导航
        </h1>
        <p className="mt-4 text-muted-foreground">
          精选智谱AI GLM 生态学习资源
        </p>
      </div>

      {resources.length === 0 ? (
        <div className="mx-auto max-w-2xl text-center py-12">
          <p className="text-muted-foreground">
            暂无资源数据，请先在 Supabase 中配置。
          </p>
        </div>
      ) : (
        <div className="mx-auto max-w-5xl space-y-10">
          {Object.entries(grouped).map(([category, items]) => {
            const config = categoryConfig[category as ResourceCategory] ||
              categoryConfig.docs;
            const Icon = config.icon;

            return (
              <section key={category}>
                <div className="flex items-center gap-2 mb-4">
                  <Icon className={`h-5 w-5 ${config.color}`} />
                  <h2 className="text-xl font-semibold">{config.label}</h2>
                  <Badge variant="secondary">{items.length}</Badge>
                </div>
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {items.map((resource) => (
                    <Card
                      key={resource.id}
                      className="transition-shadow hover:shadow-md"
                    >
                      <CardHeader className="pb-3">
                        <CardTitle className="text-base flex items-start justify-between gap-2">
                          <span className="line-clamp-1">{resource.title}</span>
                          <ExternalLink className="h-4 w-4 shrink-0 text-muted-foreground" />
                        </CardTitle>
                        <CardDescription className="line-clamp-2 text-sm">
                          {resource.description}
                        </CardDescription>
                      </CardHeader>
                      <CardContent className="pt-0">
                        <div className="flex items-center justify-between">
                          <div className="flex flex-wrap gap-1">
                            {resource.tags?.slice(0, 3).map((tag) => (
                              <Badge key={tag} variant="outline" className="text-xs">
                                {tag}
                              </Badge>
                            ))}
                          </div>
                          <a
                            href={resource.url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-xs text-blue-600 hover:underline"
                          >
                            访问 →
                          </a>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </section>
            );
          })}
        </div>
      )}
    </div>
  );
}

// Helper to avoid duplicate function name
async function ResourcesPage_getResources(): Promise<Resource[]> {
  return getResources();
}
