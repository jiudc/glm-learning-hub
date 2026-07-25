import { supabase } from "@/lib/supabase";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CheckCircle2, Circle, Clock, ChevronRight } from "lucide-react";
import type { LearningPath, LearningStage, StageStatus } from "@/types/database";

async function getLearningPaths(): Promise<
  (LearningPath & { stages: LearningStage[] })[]
> {
  const { data: paths, error } = await supabase
    .from("learning_paths")
    .select(
      `
      *,
      stages:learning_stages(*)
    `
    )
    .order("sort_order");

  if (error || !paths) {
    return [];
  }

  return paths.map((path) => ({
    ...path,
    stages: (path.stages as LearningStage[]).sort(
      (a, b) => a.sort_order - b.sort_order
    ),
  }));
}

function StatusIcon({ status }: { status: StageStatus }) {
  switch (status) {
    case "completed":
      return <CheckCircle2 className="h-5 w-5 text-green-600" />;
    case "in_progress":
      return <Clock className="h-5 w-5 text-yellow-600" />;
    default:
      return <Circle className="h-5 w-5 text-muted-foreground" />;
  }
}

function StatusBadge({ status }: { status: StageStatus }) {
  const labels = {
    not_started: "未开始",
    in_progress: "进行中",
    completed: "已完成",
  };
  const variants = {
    not_started: "secondary",
    in_progress: "default",
    completed: "outline",
  } as const;
  return (
    <Badge variant={variants[status]} className="text-xs">
      {labels[status]}
    </Badge>
  );
}

export default async function PathsPage() {
  const paths = await getLearningPaths();

  if (paths.length === 0) {
    return (
      <div className="container py-20 text-center">
        <h1 className="text-3xl font-bold tracking-tight">学习路径</h1>
        <p className="mt-4 text-muted-foreground">
          暂无学习路径数据，请先在 Supabase 中配置。
        </p>
      </div>
    );
  }

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl text-center mb-12">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          学习路径
        </h1>
        <p className="mt-4 text-muted-foreground">
          系统化的 GLM 学习路线，从入门到精通
        </p>
      </div>

      <div className="mx-auto max-w-4xl space-y-8">
        {paths.map((path, index) => {
          const completedCount = path.stages.filter(
            (s) => s.status === "completed"
          ).length;
          const progress = Math.round(
            (completedCount / path.stages.length) * 100
          );

          return (
            <Card key={path.id} className="overflow-hidden">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-blue-600 font-bold dark:bg-blue-900/30">
                      {index + 1}
                    </div>
                    <div>
                      <CardTitle className="text-xl">{path.title}</CardTitle>
                      <CardDescription>{path.description}</CardDescription>
                    </div>
                  </div>
                  <Badge variant="secondary">{progress}%</Badge>
                </div>
                {/* Progress bar */}
                <div className="mt-4 h-2 w-full rounded-full bg-muted">
                  <div
                    className="h-full rounded-full bg-blue-600 transition-all"
                    style={{ width: `${progress}%` }}
                  />
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {path.stages.map((stage) => (
                    <div
                      key={stage.id}
                      className="flex items-center justify-between rounded-lg border p-3 hover:bg-muted/50 transition-colors"
                    >
                      <div className="flex items-center gap-3">
                        <StatusIcon status={stage.status} />
                        <div>
                          <p className="font-medium">{stage.title}</p>
                          {stage.description && (
                            <p className="text-sm text-muted-foreground">
                              {stage.description}
                            </p>
                          )}
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <StatusBadge status={stage.status} />
                        <ChevronRight className="h-4 w-4 text-muted-foreground" />
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
