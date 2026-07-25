"use client";

import { useState, useEffect } from "react";
import { useLearningProgress } from "@/hooks/use-learning-progress";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  BookOpen,
  CheckCircle2,
  Clock,
  Target,
  TrendingUp,
  Flame,
  Award,
  RotateCcw,
} from "lucide-react";
import Link from "next/link";

export default function DashboardPage() {
  const { progress, isLoaded, getStats } = useLearningProgress();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted || !isLoaded) {
    return (
      <div className="container py-12 text-center text-muted-foreground">
        加载中...
      </div>
    );
  }

  const stats = getStats();
  const streak = Object.values(progress).filter(
    (p) => p.lastVisited > Date.now() - 24 * 60 * 60 * 1000
  ).length;

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-4xl">
        <div className="mb-10">
          <h1 className="text-3xl font-bold tracking-tight">学习仪表盘</h1>
          <p className="mt-2 text-muted-foreground">
            追踪你的学习进度，保持每日连续
          </p>
        </div>

        {/* 统计卡片 */}
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-8">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                已完成
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-5 w-5 text-green-600" />
                <span className="text-2xl font-bold">{stats.completed}</span>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                进行中
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <Target className="h-5 w-5 text-yellow-600" />
                <span className="text-2xl font-bold">{stats.inProgress}</span>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                需复习
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <RotateCcw className="h-5 w-5 text-red-600" />
                <span className="text-2xl font-bold">{stats.wrongCount}</span>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                今日学习
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-2">
                <Flame className="h-5 w-5 text-orange-600" />
                <span className="text-2xl font-bold">{streak}</span>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* 技能雷达图（简化版） */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5" />
              技能成长
            </CardTitle>
            <CardDescription>
              基于你已完成的学习内容
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              {[
                { name: "RAG", level: 85, color: "bg-blue-500" },
                { name: "Agent", level: 70, color: "bg-purple-500" },
                { name: "系统设计", level: 60, color: "bg-emerald-500" },
                { name: "项目实战", level: 75, color: "bg-amber-500" },
              ].map((skill) => (
                <div key={skill.name} className="text-center">
                  <div className="relative h-24 w-24 mx-auto mb-2">
                    <svg className="h-full w-full -rotate-90" viewBox="0 0 100 100">
                      <circle
                        cx="50"
                        cy="50"
                        r="40"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="8"
                        className="text-muted"
                      />
                      <circle
                        cx="50"
                        cy="50"
                        r="40"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="8"
                        strokeDasharray={`${skill.level * 2.51} 251`}
                        className={skill.color.replace("bg-", "text-")}
                      />
                    </svg>
                    <span className="absolute inset-0 flex items-center justify-center text-lg font-bold">
                      {skill.level}%
                    </span>
                  </div>
                  <p className="text-sm font-medium">{skill.name}</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* 快速操作 */}
        <div className="grid gap-4 sm:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle className="text-base">继续学习</CardTitle>
              <CardDescription>从上次离开的地方继续</CardDescription>
            </CardHeader>
            <CardContent>
              <Button className="w-full" asChild>
                <Link href="/mock-interview/random">
                  <BookOpen className="mr-2 h-4 w-4" />
                  开始练习
                </Link>
              </Button>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle className="text-base">错题本</CardTitle>
              <CardDescription>复习标记为困难的题目</CardDescription>
            </CardHeader>
            <CardContent>
              <Button className="w-full" variant="outline" asChild>
                <Link href="/interview?filter=wrong">
                  <Award className="mr-2 h-4 w-4" />
                  查看错题 ({stats.wrongCount})
                </Link>
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
