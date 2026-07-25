import Link from "next/link";
import {
  BookOpen,
  Compass,
  FileText,
  TrendingUp,
  ArrowRight,
  Sparkles,
  Code2,
  Brain,
  Bot,
  CheckCircle2,
  Clock,
  Circle,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { supabase } from "@/lib/supabase";

const features = [
  {
    icon: BookOpen,
    title: "学习路径",
    description: "从 GLM 入门到 Agent 开发的系统化学习路线",
    href: "/paths",
    color: "text-blue-600",
  },
  {
    icon: Compass,
    title: "资源导航",
    description: "官方文档、GitHub、教程、论文一站式导航",
    href: "/resources",
    color: "text-green-600",
  },
  {
    icon: FileText,
    title: "学习笔记",
    description: "个人学习心得、代码片段、踩坑记录",
    href: "/notes",
    color: "text-purple-600",
  },
  {
    icon: TrendingUp,
    title: "进度追踪",
    description: "可视化学习进度，记录成长轨迹",
    href: "/paths",
    color: "text-orange-600",
  },
];

const highlights = [
  {
    icon: Sparkles,
    title: "GLM-5.2 开源",
    description: "旗舰推理模型，与 Anthropic、OpenAI 并列前三",
  },
  {
    icon: Bot,
    title: "AutoGLM Agent",
    description: "自主规划、推理、执行的 Agent 模型",
  },
  {
    icon: Code2,
    title: "CogAgent-9B",
    description: "开源 GUI Agent 基座，仅需屏幕截图输入",
  },
  {
    icon: Brain,
    title: "全模态能力",
    description: "文本、图像、代码多模态理解与生成",
  },
];

async function getStats() {
  const [pathsResult, stagesResult, notesResult, resourcesResult] =
    await Promise.all([
      supabase.from("learning_paths").select("id", { count: "exact" }),
      supabase.from("learning_stages").select("id, status"),
      supabase.from("notes").select("id", { count: "exact" }),
      supabase.from("resources").select("id", { count: "exact" }),
    ]);

  const totalStages = stagesResult.data?.length || 0;
  const completedStages =
    stagesResult.data?.filter((s) => s.status === "completed").length || 0;
  const inProgressStages =
    stagesResult.data?.filter((s) => s.status === "in_progress").length || 0;
  const progress =
    totalStages > 0
      ? Math.round((completedStages / totalStages) * 100)
      : 0;

  return {
    pathsCount: pathsResult.count || 0,
    totalStages,
    completedStages,
    inProgressStages,
    progress,
    notesCount: notesResult.count || 0,
    resourcesCount: resourcesResult.count || 0,
  };
}

export default async function HomePage() {
  const stats = await getStats();

  return (
    <div className="flex flex-col">
      {/* Hero Section */}
      <section className="relative overflow-hidden border-b bg-gradient-to-b from-background to-muted/30">
        <div className="container py-20 md:py-28">
          <div className="mx-auto max-w-3xl text-center">
            <Badge className="mb-4" variant="secondary">
              智谱AI 开源学习
            </Badge>
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
              GLM Learning Hub
            </h1>
            <p className="mt-6 text-lg text-muted-foreground md:text-xl">
              智谱AI GLM 系列开源模型的学习知识库。
              <br className="hidden sm:inline" />
              系统化学习路径 · 精选资源导航 · 个人笔记整理
            </p>
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <Button size="lg" asChild>
                <Link href="/paths">
                  开始学习
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <Link href="/resources">浏览资源</Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Dashboard */}
      <section className="container py-12 md:py-16">
        <div className="mx-auto max-w-4xl">
          <h2 className="text-2xl font-bold tracking-tight mb-6 text-center">
            学习概览
          </h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-3xl font-bold text-blue-600">
                  {stats.progress}%
                </CardTitle>
                <CardDescription>总体进度</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="h-2 w-full rounded-full bg-muted">
                  <div
                    className="h-full rounded-full bg-blue-600 transition-all"
                    style={{ width: `${stats.progress}%` }}
                  />
                </div>
              </CardContent>
            </Card>
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-3xl font-bold text-green-600">
                  <CheckCircle2 className="inline h-7 w-7" /> {stats.completedStages}
                </CardTitle>
                <CardDescription>已完成阶段</CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                共 {stats.totalStages} 个阶段
              </CardContent>
            </Card>
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-3xl font-bold text-purple-600">
                  <FileText className="inline h-7 w-7" /> {stats.notesCount}
                </CardTitle>
                <CardDescription>学习笔记</CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                持续积累中
              </CardContent>
            </Card>
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-3xl font-bold text-orange-600">
                  <Compass className="inline h-7 w-7" /> {stats.resourcesCount}
                </CardTitle>
                <CardDescription>精选资源</CardDescription>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">
                涵盖 {stats.pathsCount} 条学习路径
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="border-t bg-muted/30 py-16 md:py-20">
        <div className="container">
          <div className="mx-auto max-w-2xl text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight">核心功能</h2>
            <p className="mt-4 text-muted-foreground">
              全方位支持你的 GLM 学习之旅
            </p>
          </div>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {features.map((feature) => (
              <Card
                key={feature.title}
                className="transition-shadow hover:shadow-md bg-background"
              >
                <CardHeader>
                  <feature.icon className={`h-10 w-10 ${feature.color}`} />
                  <CardTitle className="mt-4">{feature.title}</CardTitle>
                  <CardDescription>{feature.description}</CardDescription>
                </CardHeader>
                <CardContent>
                  <Button variant="ghost" size="sm" asChild>
                    <Link href={feature.href}>
                      前往
                      <ArrowRight className="ml-1 h-3 w-3" />
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Highlights Section */}
      <section className="border-t py-16 md:py-20">
        <div className="container">
          <div className="mx-auto max-w-2xl text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight">最新亮点</h2>
            <p className="mt-4 text-muted-foreground">
              智谱AI 开源生态最新动态
            </p>
          </div>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {highlights.map((item) => (
              <Card key={item.title} className="border-0 bg-muted/30">
                <CardHeader>
                  <item.icon className="h-8 w-8 text-blue-600" />
                  <CardTitle className="text-base">{item.title}</CardTitle>
                  <CardDescription className="text-sm">
                    {item.description}
                  </CardDescription>
                </CardHeader>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="container py-16 md:py-20">
        <Card className="mx-auto max-w-2xl text-center bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-950/20 dark:to-purple-950/20 border-0">
          <CardHeader className="pb-4">
            <CardTitle className="text-2xl">开始你的 GLM 学习之旅</CardTitle>
            <CardDescription>
              从基础概念到高级应用，循序渐进掌握智谱AI技术栈
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button size="lg" asChild>
              <Link href="/paths">
                查看学习路径
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
