import { supabase } from "@/lib/supabase";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Building2, Lightbulb } from "lucide-react";
import type { InterviewQuestion } from "@/types/database";

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

        {question.hint && (
          <div className="mb-6 rounded-lg border bg-muted/30 p-4">
            <div className="flex items-center gap-2 mb-2">
              <Lightbulb className="h-4 w-4 text-yellow-600" />
              <span className="font-medium text-sm">提示</span>
            </div>
            <p className="text-sm text-muted-foreground">{question.hint}</p>
          </div>
        )}

        {question.answer && (
          <div className="prose prose-neutral dark:prose-invert max-w-none">
            <h2 className="text-xl font-semibold mb-4">参考答案</h2>
            {question.answer.split('\n').map((line, i) => {
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
        )}
      </article>
    </div>
  );
}
