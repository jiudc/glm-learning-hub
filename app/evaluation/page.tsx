import { supabase } from "@/lib/supabase";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Search, Bot, Brain, Shield } from "lucide-react";
import type { EvaluationMetric } from "@/types/database";

async function getMetrics(): Promise<EvaluationMetric[]> {
  const { data, error } = await supabase
    .from("evaluation_metrics")
    .select("*")
    .order("category");

  if (error || !data) return [];
  return data;
}

const categoryConfig: Record<string, { label: string; icon: typeof Search; color: string }> = {
  rag: { label: "RAG 评估", icon: Search, color: "text-blue-600" },
  agent: { label: "Agent 评估", icon: Bot, color: "text-purple-600" },
  model: { label: "模型能力", icon: Brain, color: "text-green-600" },
  safety: { label: "安全评估", icon: Shield, color: "text-red-600" },
};

export default async function EvaluationPage() {
  const metrics = await getMetrics();

  const grouped = metrics.reduce((acc, m) => {
    const cat = m.category || "model";
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(m);
    return acc;
  }, {} as Record<string, EvaluationMetric[]>);

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl text-center mb-10">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          评估指标百科
        </h1>
        <p className="mt-3 text-muted-foreground">
          RAGAS · lm-eval-harness · TruLens · Arize Phoenix
        </p>
      </div>

      {metrics.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground">
          <p>暂无评估指标数据，请先在 Supabase 中执行 seed_v2.sql</p>
        </div>
      ) : (
        <div className="mx-auto max-w-5xl space-y-10">
          {Object.entries(grouped).map(([category, items]) => {
            const config = categoryConfig[category] || categoryConfig.model;
            const Icon = config.icon;

            return (
              <section key={category}>
                <div className="flex items-center gap-2 mb-4">
                  <Icon className={`h-5 w-5 ${config.color}`} />
                  <h2 className="text-xl font-semibold">{config.label}</h2>
                  <Badge variant="secondary">{items.length}</Badge>
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  {items.map((metric) => (
                    <Card key={metric.id}>
                      <CardHeader className="pb-3">
                        <div className="flex items-center justify-between">
                          <CardTitle className="text-base">{metric.name}</CardTitle>
                          {metric.tool && (
                            <Badge variant="outline" className="text-xs">{metric.tool}</Badge>
                          )}
                        </div>
                        <CardDescription className="text-sm">
                          {metric.description}
                        </CardDescription>
                      </CardHeader>
                      <CardContent className="space-y-2">
                        {metric.formula && (
                          <div className="text-xs bg-muted rounded p-2 font-mono">
                            {metric.formula}
                          </div>
                        )}
                        {metric.use_case && (
                          <p className="text-xs text-muted-foreground">
                            用途：{metric.use_case}
                          </p>
                        )}
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
