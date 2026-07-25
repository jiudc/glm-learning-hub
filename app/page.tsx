import Link from "next/link";
import {
  Search,
  Bot,
  Building2,
  Briefcase,
  ArrowRight,
  Sparkles,
  Code2,
  Brain,
  CheckCircle2,
  Clock,
  Zap,
  Target,
  Shield,
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

const modules = [
  {
    icon: Search,
    title: "RAG 系统设计与实战",
    slug: "rag-master",
    description: "从 Naive RAG 到 Agentic RAG 完整链路：文档处理、向量检索、混合搜索、重排序、RAGAS 评估。大厂面试占比 ~40%。",
    color: "text-blue-600",
    bgColor: "bg-blue-50 dark:bg-blue-950/20",
    hours: 40,
    level: "中级 → 高级",
  },
  {
    icon: Bot,
    title: "LLM Agent 开发进阶",
    slug: "llm-agent",
    description: "ReAct、LangGraph 多代理协作、Function Calling 安全、Agent 评估。涵盖智谱 AutoGLM 和 CogAgent 生态。2025 最热方向。",
    color: "text-purple-600",
    bgColor: "bg-purple-50 dark:bg-purple-950/20",
    hours: 50,
    level: "高级 → 专家",
  },
  {
    icon: Building2,
    title: "系统设计面试专练",
    slug: "system-design-interview",
    description: "5 大高频 LLM 场景系统设计：ChatGPT、智能客服、代码助手、文档问答、AI 搜索。每题含架构图、API 设计、Trade-off。",
    color: "text-green-600",
    bgColor: "bg-green-50 dark:bg-green-950/20",
    hours: 30,
    level: "高级",
  },
  {
    icon: Briefcase,
    title: "项目作品集",
    slug: "project-portfolio",
    description: "5 个梯度项目从易到难，每个含技术栈、架构图、代码、面试话术。证明你能独立交付完整 LLM 应用。",
    color: "text-orange-600",
    bgColor: "bg-orange-50 dark:bg-orange-950/20",
    hours: 60,
    level: "中级 → 高级",
  },
];

const highlights = [
  {
    icon: Sparkles,
    title: "GLM-5 开源",
    description: "旗舰推理模型，10T tokens 预训练，中英文 SOTA",
  },
  {
    icon: Bot,
    title: "AutoGLM Agent",
    description: "自主完成 50+ 步骤复杂任务，跨应用跨设备",
  },
  {
    icon: Code2,
    title: "CogAgent-9B",
    description: "18B 视觉语言模型，GUI 导航 SOTA",
  },
  {
    icon: Brain,
    title: "vLLM + PagedAttention",
    description: "推理吞吐量 2-4x 提升，显存利用率 95%",
  },
];

async function getStats() {
  const [pathsResult, coursesResult, questionsResult, projectsResult] =
    await Promise.all([
      supabase.from("learning_paths").select("id", { count: "exact" }),
      supabase.from("courses").select("id", { count: "exact" }),
      supabase.from("interview_questions").select("id", { count: "exact" }),
      supabase.from("projects").select("id", { count: "exact" }),
    ]);

  return {
    pathsCount: pathsResult.count || 0,
    coursesCount: coursesResult.count || 0,
    questionsCount: questionsResult.count || 0,
    projectsCount: projectsResult.count || 0,
  };
}

export default async function HomePage() {
  const stats = await getStats();

  return (
    <div className="flex flex-col">
      {/* Hero */}
      <section className="relative overflow-hidden border-b bg-gradient-to-b from-background to-muted/30">
        <div className="container py-16 md:py-24">
          <div className="mx-auto max-w-3xl text-center">
            <Badge className="mb-4" variant="secondary">
              大模型应用工程师进阶平台
            </Badge>
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
              GLM Learning Hub
            </h1>
            <p className="mt-4 text-lg text-muted-foreground">
              系统化掌握 LLM 应用开发，通过大厂面试
            </p>
            <p className="mt-2 text-sm text-muted-foreground">
              RAG · Agent · 系统设计 · 项目实战 · 评估体系
            </p>
            <div className="mt-6 flex flex-wrap items-center justify-center gap-3">
              <Button size="lg" asChild>
                <Link href="/paths">
                  开始学习
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <Link href="/interview">刷面试题</Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="container py-10">
        <div className="mx-auto max-w-4xl">
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-2xl font-bold text-blue-600">
                  {stats.pathsCount}
                </CardTitle>
                <CardDescription>学习模块</CardDescription>
              </CardHeader>
            </Card>
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-2xl font-bold text-purple-600">
                  {stats.coursesCount}
                </CardTitle>
                <CardDescription>课程</CardDescription>
              </CardHeader>
            </Card>
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-2xl font-bold text-green-600">
                  {stats.questionsCount}
                </CardTitle>
                <CardDescription>面试题</CardDescription>
              </CardHeader>
            </Card>
            <Card className="text-center">
              <CardHeader className="pb-2">
                <CardTitle className="text-2xl font-bold text-orange-600">
                  {stats.projectsCount}
                </CardTitle>
                <CardDescription>项目作品</CardDescription>
              </CardHeader>
            </Card>
          </div>
        </div>
      </section>

      {/* 4 大模块 */}
      <section className="border-t bg-muted/30 py-12 md:py-16">
        <div className="container">
          <div className="mx-auto max-w-2xl text-center mb-10">
            <h2 className="text-3xl font-bold tracking-tight">4 大核心模块</h2>
            <p className="mt-3 text-muted-foreground">
              从基础到面试，系统化掌握 LLM 应用开发
            </p>
          </div>
          <div className="mx-auto max-w-5xl grid gap-6 sm:grid-cols-2">
            {modules.map((mod) => (
              <Link key={mod.slug} href={`/paths/${mod.slug}`}>
                <Card className="h-full transition-shadow hover:shadow-md">
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <div className={`p-2 rounded-lg ${mod.bgColor}`}>
                        <mod.icon className={`h-6 w-6 ${mod.color}`} />
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge variant="outline">{mod.level}</Badge>
                        <Badge variant="secondary">{mod.hours}h</Badge>
                      </div>
                    </div>
                    <CardTitle className="mt-3 text-xl">{mod.title}</CardTitle>
                    <CardDescription className="text-sm">
                      {mod.description}
                    </CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Button variant="ghost" size="sm">
                      开始学习
                      <ArrowRight className="ml-1 h-3 w-3" />
                    </Button>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* 技术亮点 */}
      <section className="border-t py-12 md:py-16">
        <div className="container">
          <div className="mx-auto max-w-2xl text-center mb-10">
            <h2 className="text-3xl font-bold tracking-tight">技术亮点</h2>
            <p className="mt-3 text-muted-foreground">
              覆盖 2025-2026 最新技术栈
            </p>
          </div>
          <div className="mx-auto max-w-5xl grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
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

      {/* CTA */}
      <section className="container py-12 md:py-16">
        <Card className="mx-auto max-w-2xl text-center bg-gradient-to-br from-blue-50 to-purple-50 dark:from-blue-950/20 dark:to-purple-950/20 border-0">
          <CardHeader className="pb-4">
            <CardTitle className="text-2xl">准备就绪？</CardTitle>
            <CardDescription>
              从 RAG 基础开始，逐步掌握 LLM 应用开发全套技能
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-wrap justify-center gap-3">
            <Button size="lg" asChild>
              <Link href="/paths/rag-master">
                <Search className="mr-2 h-4 w-4" />
                从 RAG 开始
              </Link>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <Link href="/interview">直接刷题</Link>
            </Button>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
