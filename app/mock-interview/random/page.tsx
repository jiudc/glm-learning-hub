"use client";

import { useState, useEffect, useCallback } from "react";
import { supabase } from "@/lib/supabase";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Shuffle,
  ChevronLeft,
  ChevronRight,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Lightbulb,
  Eye,
} from "lucide-react";
import Link from "next/link";

interface Question {
  id: string;
  question: string;
  hint: string | null;
  answer: string;
  difficulty: string;
  category: string;
  company_tag: string[] | null;
}

type Stage = "think" | "hint" | "answer" | "score";

export default function RandomPracticePage() {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [stage, setStage] = useState<Stage>("think");
  const [score, setScore] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("interview_questions")
      .select("id, question, hint, answer, difficulty, category, company_tag")
      .then(({ data }) => {
        if (data) {
          // 随机打乱
          const shuffled = [...data].sort(() => Math.random() - 0.5);
          setQuestions(shuffled);
        }
        setLoading(false);
      });
  }, []);

  const current = questions[currentIndex];

  const goNext = useCallback(() => {
    if (currentIndex < questions.length - 1) {
      setCurrentIndex((i) => i + 1);
      setStage("think");
      setScore(null);
    }
  }, [currentIndex, questions.length]);

  const goPrev = useCallback(() => {
    if (currentIndex > 0) {
      setCurrentIndex((i) => i - 1);
      setStage("think");
      setScore(null);
    }
  }, [currentIndex]);

  const reset = useCallback(() => {
    setStage("think");
    setScore(null);
  }, []);

  if (loading) {
    return (
      <div className="container py-12 text-center text-muted-foreground">
        加载中...
      </div>
    );
  }

  if (!current) {
    return (
      <div className="container py-12 text-center text-muted-foreground">
        暂无题目
      </div>
    );
  }

  const difficultyConfig: Record<string, { label: string; color: string }> = {
    easy: { label: "简单", color: "bg-green-100 text-green-700" },
    medium: { label: "中等", color: "bg-yellow-100 text-yellow-700" },
    hard: { label: "困难", color: "bg-red-100 text-red-700" },
    expert: { label: "专家", color: "bg-purple-100 text-purple-700" },
  };

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl">
        {/* 顶部导航 */}
        <div className="flex items-center justify-between mb-6">
          <Button variant="ghost" size="sm" asChild>
            <Link href="/mock-interview">
              <ChevronLeft className="mr-2 h-4 w-4" />
              返回
            </Link>
          </Button>
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <Shuffle className="h-4 w-4" />
            {currentIndex + 1} / {questions.length}
          </div>
        </div>

        {/* 题目卡片 */}
        <div className="rounded-lg border p-6 mb-6">
          <div className="flex flex-wrap items-center gap-2 mb-4">
            <Badge variant="secondary">{current.category}</Badge>
            <Badge className={difficultyConfig[current.difficulty]?.color || ""}>
              {difficultyConfig[current.difficulty]?.label || current.difficulty}
            </Badge>
            {current.company_tag?.slice(0, 2).map((c) => (
              <Badge key={c} variant="outline" className="text-xs">{c}</Badge>
            ))}
          </div>
          <h2 className="text-xl font-bold tracking-tight">{current.question}</h2>
        </div>

        {/* 渐进式答案 */}
        <div className="rounded-lg border p-6 mb-6">
          {stage === "think" && (
            <div className="text-center py-6 space-y-4">
              <p className="text-muted-foreground">💡 先自己思考，组织答案</p>
              <div className="flex justify-center gap-3">
                <Button onClick={() => setStage("hint")} variant="outline">
                  <Lightbulb className="mr-2 h-4 w-4" />
                  查看提示
                </Button>
                <Button onClick={() => setStage("answer")}>
                  <Eye className="mr-2 h-4 w-4" />
                  直接看答案
                </Button>
              </div>
            </div>
          )}

          {stage === "hint" && (
            <div className="space-y-4">
              <div className="rounded-lg bg-yellow-50 dark:bg-yellow-950/20 p-4">
                <div className="flex items-center gap-2 mb-2">
                  <Lightbulb className="h-4 w-4 text-yellow-600" />
                  <span className="font-medium text-sm">提示</span>
                </div>
                <p className="text-sm text-muted-foreground">
                  {current.hint || "先思考这个问题涉及哪些核心模块？"}
                </p>
              </div>
              <Button onClick={() => setStage("answer")} className="w-full">
                <Eye className="mr-2 h-4 w-4" />
                查看参考答案
              </Button>
            </div>
          )}

          {stage === "answer" && (
            <div className="space-y-4">
              <h3 className="text-lg font-semibold">参考答案</h3>
              <div className="prose prose-neutral dark:prose-invert max-w-none text-sm">
                {current.answer.split("\n").map((line, i) => {
                  if (line.startsWith("# ")) return <h1 key={i} className="text-xl font-bold mt-4 mb-2">{line.slice(2)}</h1>;
                  if (line.startsWith("## ")) return <h2 key={i} className="text-lg font-semibold mt-3 mb-2">{line.slice(3)}</h2>;
                  if (line.startsWith("### ")) return <h3 key={i} className="text-base font-semibold mt-2 mb-1">{line.slice(4)}</h3>;
                  if (line.startsWith("- ")) return <li key={i} className="ml-4 text-foreground/80">{line.slice(2)}</li>;
                  if (line.trim() === "") return <br key={i} />;
                  return <p key={i} className="text-foreground/80">{line}</p>;
                })}
              </div>

              {/* 自我评分 */}
              <div className="border-t pt-4 mt-4">
                <p className="text-sm text-muted-foreground mb-3">自我评分：</p>
                <div className="flex gap-2">
                  <Button
                    variant={score === 1 ? "default" : "outline"}
                    size="sm"
                    onClick={() => setScore(1)}
                  >
                    <XCircle className="mr-1 h-4 w-4" />
                    需要重做
                  </Button>
                  <Button
                    variant={score === 2 ? "default" : "outline"}
                    size="sm"
                    onClick={() => setScore(2)}
                  >
                    部分理解
                  </Button>
                  <Button
                    variant={score === 3 ? "default" : "outline"}
                    size="sm"
                    onClick={() => setScore(3)}
                  >
                    <CheckCircle2 className="mr-1 h-4 w-4" />
                    已掌握
                  </Button>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* 底部导航 */}
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={goPrev} disabled={currentIndex === 0}>
            <ChevronLeft className="mr-2 h-4 w-4" />
            上一题
          </Button>
          <div className="flex gap-2">
            <Button variant="ghost" onClick={reset}>
              <RotateCcw className="mr-2 h-4 w-4" />
              重置
            </Button>
            <Button onClick={goNext} disabled={currentIndex === questions.length - 1}>
              下一题
              <ChevronRight className="ml-2 h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
