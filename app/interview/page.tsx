import { supabase } from "@/lib/supabase";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Search, MessageSquare, Code2, Lightbulb, Building2, Briefcase } from "lucide-react";
import Link from "next/link";
import type { InterviewQuestion } from "@/types/database";

async function getQuestions(): Promise<InterviewQuestion[]> {
  const { data, error } = await supabase
    .from("interview_questions")
    .select("*")
    .order("sort_order");

  if (error || !data) return [];
  return data;
}

const categoryConfig: Record<string, { label: string; icon: typeof Search; color: string }> = {
  system_design: { label: "系统设计", icon: Building2, color: "text-blue-600" },
  algorithm: { label: "算法实现", icon: Code2, color: "text-green-600" },
  project: { label: "项目深挖", icon: Briefcase, color: "text-purple-600" },
  coding: { label: "编码题", icon: Code2, color: "text-orange-600" },
  behavioral: { label: "行为面试", icon: MessageSquare, color: "text-pink-600" },
};

const difficultyConfig: Record<string, { label: string; color: string }> = {
  easy: { label: "简单", color: "bg-green-100 text-green-700 dark:bg-green-900/30" },
  medium: { label: "中等", color: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30" },
  hard: { label: "困难", color: "bg-red-100 text-red-700 dark:bg-red-900/30" },
  expert: { label: "专家", color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30" },
};

export default async function InterviewPage() {
  const questions = await getQuestions();

  const grouped = questions.reduce((acc, q) => {
    if (!acc[q.category]) acc[q.category] = [];
    acc[q.category].push(q);
    return acc;
  }, {} as Record<string, InterviewQuestion[]>);

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl text-center mb-10">
        <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
          面试题库
        </h1>
        <p className="mt-3 text-muted-foreground">
          系统设计 · 算法 · 项目深挖 · 编码 · 行为面试
        </p>
        <p className="mt-1 text-sm text-muted-foreground">
          共 {questions.length} 道题，含参考答案和追问方向
        </p>
      </div>

      {questions.length === 0 ? (
        <div className="text-center py-12 text-muted-foreground">
          <p>暂无面试题数据，请先在 Supabase 中执行 seed_v2_final.sql</p>
        </div>
      ) : (
        <div className="mx-auto max-w-5xl space-y-10">
          {Object.entries(grouped).map(([category, items]) => {
            const config = categoryConfig[category] || categoryConfig.system_design;
            const Icon = config.icon;

            return (
              <section key={category}>
                <div className="flex items-center gap-2 mb-4">
                  <Icon className={`h-5 w-5 ${config.color}`} />
                  <h2 className="text-xl font-semibold">{config.label}</h2>
                  <Badge variant="secondary">{items.length}</Badge>
                </div>
                <div className="space-y-3">
                  {items.map((q) => (
                    <Card key={q.id} className="transition-shadow hover:shadow-md">
                      <CardHeader className="pb-3">
                        <div className="flex items-start justify-between gap-3">
                          <div className="min-w-0 flex-1">
                            <Link href={`/interview/${q.id}`}>
                              <CardTitle className="text-base hover:text-blue-600 transition-colors">
                                {q.question}
                              </CardTitle>
                            </Link>
                            {q.hint && (
                              <CardDescription className="mt-1 text-sm">
                                💡 {q.hint}
                              </CardDescription>
                            )}
                          </div>
                          <div className="flex items-center gap-2 shrink-0">
                            {q.company_tag?.slice(0, 2).map((company) => (
                              <Badge key={company} variant="outline" className="text-xs">
                                {company}
                              </Badge>
                            ))}
                            <Badge
                              variant="secondary"
                              className={`text-xs ${difficultyConfig[q.difficulty]?.color || ""}`}
                            >
                              {difficultyConfig[q.difficulty]?.label || q.difficulty}
                            </Badge>
                          </div>
                        </div>
                      </CardHeader>
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
