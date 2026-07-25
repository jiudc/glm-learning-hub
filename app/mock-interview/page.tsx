import { supabase } from "@/lib/supabase";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Play,
  Shuffle,
  Clock,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Trophy,
} from "lucide-react";
import Link from "next/link";

async function getQuestions() {
  const { data, error } = await supabase
    .from("interview_questions")
    .select("id, question, difficulty, category")
    .order("sort_order");

  if (error || !data) return [];
  return data;
}

export default async function MockInterviewPage() {
  const questions = await getQuestions();

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl">
        <div className="text-center mb-10">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            模拟面试
          </h1>
          <p className="mt-3 text-muted-foreground">
            随机抽题 + 倒计时 + 自我评分，模拟真实面试环境
          </p>
        </div>

        {/* 面试模式选择 */}
        <div className="grid gap-4 sm:grid-cols-2 mb-10">
          <div className="rounded-lg border p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center gap-3 mb-3">
              <div className="p-2 rounded-lg bg-blue-100 dark:bg-blue-900/30">
                <Shuffle className="h-5 w-5 text-blue-600" />
              </div>
              <h3 className="text-lg font-semibold">随机练习</h3>
            </div>
            <p className="text-sm text-muted-foreground mb-4">
              从题库中随机抽取题目，不限时间，适合日常练习
            </p>
            <Button className="w-full" asChild>
              <Link href="/mock-interview/random">
                <Play className="mr-2 h-4 w-4" />
                开始随机练习
              </Link>
            </Button>
          </div>

          <div className="rounded-lg border p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center gap-3 mb-3">
              <div className="p-2 rounded-lg bg-red-100 dark:bg-red-900/30">
                <Clock className="h-5 w-5 text-red-600" />
              </div>
              <h3 className="text-lg font-semibold">压力面试</h3>
            </div>
            <p className="text-sm text-muted-foreground mb-4">
              每题 15 分钟倒计时，模拟真实面试压力
            </p>
            <Button className="w-full" variant="destructive" asChild>
              <Link href="/mock-interview/timed">
                <Clock className="mr-2 h-4 w-4" />
                开始压力面试
              </Link>
            </Button>
          </div>
        </div>

        {/* 题库统计 */}
        <div className="rounded-lg border p-6">
          <h2 className="text-xl font-semibold mb-4">题库概览</h2>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div className="text-center">
              <p className="text-2xl font-bold text-blue-600">{questions.length}</p>
              <p className="text-sm text-muted-foreground">总题数</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-green-600">
                {questions.filter((q) => q.difficulty === "easy").length}
              </p>
              <p className="text-sm text-muted-foreground">简单</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-yellow-600">
                {questions.filter((q) => q.difficulty === "medium").length}
              </p>
              <p className="text-sm text-muted-foreground">中等</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-red-600">
                {questions.filter((q) => q.difficulty === "hard" || q.difficulty === "expert").length}
              </p>
              <p className="text-sm text-muted-foreground">困难+专家</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
