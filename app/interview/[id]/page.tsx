import { supabase } from "@/lib/supabase";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Building2, Clock, CheckCircle2 } from "lucide-react";
import type { InterviewQuestion } from "@/types/database";
import { ProgressiveAnswer } from "@/components/interview/progressive-answer";

async function getQuestion(id: string): Promise<InterviewQuestion | null> {
  const { data, error } = await supabase
    .from("interview_questions")
    .select("*")
    .eq("id", id)
    .single();

  if (error || !data) return null;
  return data;
}

const difficultyConfig: Record<string, { label: string; color: string }> = {
  easy: { label: "简单", color: "bg-green-100 text-green-700 dark:bg-green-900/30" },
  medium: { label: "中等", color: "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30" },
  hard: { label: "困难", color: "bg-red-100 text-red-700 dark:bg-red-900/30" },
  expert: { label: "专家", color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30" },
};

interface Props {
  params: Promise<{ id: string }>;
}

export default async function QuestionDetailPage({ params }: Props) {
  const { id } = await params;
  const question = await getQuestion(id);

  if (!question) notFound();

  return (
    <div className="container py-12 md:py-16">
      <article className="mx-auto max-w-3xl">
        <Button variant="ghost" size="sm" asChild className="-ml-3 mb-6">
          <Link href="/interview">
            <ArrowLeft className="mr-2 h-4 w-4" />
            返回题库
          </Link>
        </Button>

        <header className="mb-8">
          <div className="flex flex-wrap items-center gap-2 mb-3">
            <Badge variant="secondary">{question.category}</Badge>
            <Badge className={difficultyConfig[question.difficulty]?.color || ""}>
              {difficultyConfig[question.difficulty]?.label || question.difficulty}
            </Badge>
            {question.company_tag?.map((company) => (
              <Badge key={company} variant="outline">
                <Building2 className="mr-1 h-3 w-3" />
                {company}
              </Badge>
            ))}
          </div>
          <h1 className="text-2xl font-bold tracking-tight md:text-3xl">
            {question.question}
          </h1>
        </header>

        {/* 渐进式答案展示 */}
        {question.answer && (
          <div className="rounded-lg border p-6">
            <ProgressiveAnswer hint={question.hint} answer={question.answer} />
          </div>
        )}
      </article>
    </div>
  );
}
