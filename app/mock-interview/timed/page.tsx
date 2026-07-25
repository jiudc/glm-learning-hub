"use client";

import { useState, useEffect, useCallback } from "react";
import { supabase } from "@/lib/supabase";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  ChevronLeft,
  ChevronRight,
  Clock,
  CheckCircle2,
  XCircle,
  Pause,
  Play,
} from "lucide-react";
import Link from "next/link";

interface Question {
  id: string;
  question: string;
  hint: string | null;
  answer: string;
  difficulty: string;
  category: string;
}

const TIMER_DURATION = 15 * 60; // 15 分钟（秒）

export default function TimedInterviewPage() {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [stage, setStage] = useState<"think" | "answer">("think");
  const [timeLeft, setTimeLeft] = useState(TIMER_DURATION);
  const [isRunning, setIsRunning] = useState(false);
  const [score, setScore] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("interview_questions")
      .select("id, question, hint, answer, difficulty, category")
      .then(({ data }) => {
        if (data) {
          const shuffled = [...data].sort(() => Math.random() - 0.5);
          setQuestions(shuffled);
        }
        setLoading(false);
      });
  }, []);

  // 倒计时
  useEffect(() => {
    if (!isRunning || timeLeft <= 0) return;
    const timer = setInterval(() => {
      setTimeLeft((t) => {
        if (t <= 1) {
          setIsRunning(false);
          return 0;
        }
        return t - 1;
      });
    }, 1000);
    return () => clearInterval(timer);
  }, [isRunning, timeLeft]);

  const current = questions[currentIndex];

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  };

  const goNext = useCallback(() => {
    if (currentIndex < questions.length - 1) {
      setCurrentIndex((i) => i + 1);
      setStage("think");
      setScore(null);
      setTimeLeft(TIMER_DURATION);
      setIsRunning(false);
    }
  }, [currentIndex, questions.length]);

  const goPrev = useCallback(() => {
    if (currentIndex > 0) {
      setCurrentIndex((i) => i - 1);
      setStage("think");
      setScore(null);
      setTimeLeft(TIMER_DURATION);
      setIsRunning(false);
    }
  }, [currentIndex]);

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

  const timeWarning = timeLeft < 300; // 5 分钟警告
  const timeDanger = timeLeft < 60; // 1 分钟危险

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
            {currentIndex + 1} / {questions.length}
          </div>
        </div>

        {/* 计时器 */}
        <div className="rounded-lg border p-4 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div
                className={`p-2 rounded-lg ${
                  timeDanger
                    ? "bg-red-100 dark:bg-red-900/30"
                    : timeWarning
                    ? "bg-yellow-100 dark:bg-yellow-900/30"
                    : "bg-blue-100 dark:bg-blue-900/30"
                }`}
              >
                <Clock
                  className={`h-5 w-5 ${
                    timeDanger
                      ? "text-red-600"
                      : timeWarning
                      ? "text-yellow-600"
                      : "text-blue-600"
                  }`}
                />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">剩余时间</p>
                <p
                  className={`text-2xl font-bold font-mono ${
                    timeDanger
                      ? "text-red-600"
                      : timeWarning
                      ? "text-yellow-600"
                      : ""
                  }`}
                >
                  {formatTime(timeLeft)}
                </p>
              </div>
            </div>
            <Button
              variant={isRunning ? "outline" : "default"}
              size="sm"
              onClick={() => setIsRunning(!isRunning)}
            >
              {isRunning ? (
                <>
                  <Pause className="mr-2 h-4 w-4" />
                  暂停
                </>
              ) : (
                <>
                  <Play className="mr-2 h-4 w-4" />
                  开始
                </>
              )}
            </Button>
          </div>
        </div>

        {/* 题目卡片 */}
        <div className="rounded-lg border p-6 mb-6">
          <div className="flex flex-wrap items-center gap-2 mb-4">
            <Badge variant="secondary">{current.category}</Badge>
            <Badge variant="outline">{current.difficulty}</Badge>
          </div>
          <h2 className="text-xl font-bold tracking-tight">{current.question}</h2>
        </div>

        {/* 答案区域 */}
        <div className="rounded-lg border p-6 mb-6">
          {stage === "think" ? (
            <div className="text-center py-6 space-y-4">
              <p className="text-muted-foreground">
                💡 先自己思考，组织答案。准备好后点击查看参考答案
              </p>
              <Button onClick={() => setStage("answer")}>
                查看参考答案
              </Button>
            </div>
          ) : (
            <div className="space-y-4">
              <h3 className="text-lg font-semibold">参考答案</h3>
              <div className="prose prose-neutral dark:prose-invert max-w-none text-sm">
                {current.answer.split("\n").map((line, i) => {
                  if (line.startsWith("# "))
                    return (
                      <h1 key={i} className="text-xl font-bold mt-4 mb-2">
                        {line.slice(2)}
                      </h1>
                    );
                  if (line.startsWith("## "))
                    return (
                      <h2 key={i} className="text-lg font-semibold mt-3 mb-2">
                        {line.slice(3)}
                      </h2>
                    );
                  if (line.startsWith("- "))
                    return (
                      <li key={i} className="ml-4 text-foreground/80">
                        {line.slice(2)}
                      </li>
                    );
                  if (line.trim() === "") return <br key={i} />;
                  return (
                    <p key={i} className="text-foreground/80">
                      {line}
                    </p>
                  );
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
          <Button onClick={goNext} disabled={currentIndex === questions.length - 1}>
            下一题
            <ChevronRight className="ml-2 h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
