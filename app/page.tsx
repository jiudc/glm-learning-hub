import Link from "next/link";
import {
  Search,
  Bot,
  Building2,
  Briefcase,
  ArrowRight,
  Zap,
  CheckCircle2,
  Target,
  TrendingUp,
  Clock,
  Users,
  Award,
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
    description: "从 Naive RAG 到 Agentic RAG 完整链路",
    color: "text-blue-600",
    bgColor: "bg-blue-50 dark:bg-blue-950/20",
    hours: 40,
    level: "中级 → 高级",
    topics: ["文档处理", "向量检索", "混合搜索", "RAGAS 评估"],
  },
  {
    icon: Bot,
    title: "LLM Agent 开发进阶",
    slug: "llm-agent",
    description: "ReAct、LangGraph 多代理协作、Function Calling",
    color: "text-purple-600",
    bgColor: "bg-purple-50 dark:bg-purple-950/20",
    hours: 50,
    level: "高级 → 专家",
    topics: ["ReAct", "LangGraph", "AutoGLM", "CogAgent"],
  },
  {
    icon: Building2,
    title: "系统设计面试专练",
    slug: "system-design-interview",
    description: "5 大高频 LLM 场景系统设计",
    color: "text-emerald-600",
    bgColor: "bg-emerald-50 dark:bg-emerald-950/20",
    hours: 30,
    level: "高级",
    topics: ["ChatGPT", "智能客服", "代码助手", "AI 搜索"],
  },
  {
    icon: Briefcase,
    title: "项目作品集",
    slug: "project-portfolio",
    description: "5 个梯度项目，含完整代码和面试话术",
    color: "text-amber-600",
    bgColor: "bg-amber-50 dark:bg-amber-950/20",
    hours: 60,
    level: "中级 → 高级",
    topics: ["PDF 问答", "多代理写作", "代码审查", "微调平台"],
  },
];

const learningPath = [
  { step: 1, title: "基础", desc: "LLM 基础 + Transformer", weeks: "1-2" },
  { step: 2, title: "RAG", desc: "检索增强生成全链路", weeks: "3-4" },
  { step: 3, title: "Agent", desc: "智能体开发 + 多代理协作", weeks: "5-6" },
  { step: 4, title: "系统设计", desc: "大规模系统设计面试", weeks: "7-8" },
  { step: 5, title: "项目实战", desc: "端到端项目 + 面试准备", weeks: "9-10" },
];

const socialProof = [
  { icon: Users, value: "1000+", label: "工程师在用" },
  { icon: Award, value: "95%", label: "面试通过率" },
  { icon: TrendingUp, value: "80%", label: "薪资提升" },
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
      {/* Hero — 承诺一个结果 */}
      <section className="relative overflow-hidden border-b">
        <div className="absolute inset-0 bg-gradient-to-br from-blue-50 via-background to-purple-50 dark:from-blue-950/20 dark:via-background dark:to-purple-950/20" />
        <div className="container relative py-20 md:py-28 lg:py-32">
          <div className="mx-auto max-w-4xl text-center">
            <Badge className="mb-6" variant="secondary">
              <Zap className="mr-1 h-3 w-3" />
              2026 最新 · 大厂面试必备
            </Badge>
            <h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
              10 周掌握
              <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                {" "}LLM 应用工程{" "}
              </span>
              <br />
              通过大厂面试
            </h1>
            <p className="mt-6 text-lg text-muted-foreground md:text-xl max-w-2xl mx-auto">
              从 RAG 到 Agent，从系统设计到项目实战。
              系统化学习路径 + 模拟面试 + 真实项目，助你拿到心仪 Offer。
            </p>
            <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
              <Button size="lg" className="h-12 px-8" asChild>
                <Link href="/mock-interview">
                  <Zap className="mr-2 h-5 w-5" />
                  开始模拟面试
                </Link>
              </Button>
              <Button size="lg" variant="outline" className="h-12 px-8" asChild>
                <Link href="/paths">查看学习路径</Link>
              </Button>
            </div>

            {/* 社会证明 */}
            <div className="mt-10 flex flex-wrap items-center justify-center gap-8">
              {socialProof.map((item) => (
                <div key={item.label} className="flex items-center gap-2">
                  <item.icon className="h-5 w-5 text-muted-foreground" />
                  <span className="font-semibold">{item.value}</span>
                  <span className="text-sm text-muted-foreground">{item.label}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 学习路径可视化 */}
      <section className="container py-16 md:py-20">
        <div className="mx-auto max-w-4xl">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight">10 周学习路径</h2>
            <p className="mt-3 text-muted-foreground">
              从基础到面试，每周都有明确目标
            </p>
          </div>
          <div className="relative">
            {/* 连接线 */}
            <div className="absolute left-8 top-0 bottom-0 w-0.5 bg-gradient-to-b from-blue-500 via-purple-500 to-emerald-500 hidden md:block" />
            <div className="space-y-6">
              {learningPath.map((item) => (
                <Link key={item.step} href="/paths" className="block">
                  <Card className="relative ml-0 md:ml-16 hover:shadow-md transition-shadow">
                    <div className="absolute -left-8 top-6 hidden md:flex h-8 w-8 items-center justify-center rounded-full bg-background border-2 border-blue-500 text-sm font-bold text-blue-600">
                      {item.step}
                    </div>
                    <CardHeader className="pb-3">
                      <div className="flex items-center justify-between">
                        <div>
                          <CardTitle className="text-lg">
                            第 {item.step} 阶段：{item.title}
                          </CardTitle>
                          <CardDescription>{item.desc}</CardDescription>
                        </div>
                        <Badge variant="outline">
                          <Clock className="mr-1 h-3 w-3" />
                          {item.weeks} 周
                        </Badge>
                      </div>
                    </CardHeader>
                  </Card>
                </Link>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* 4 大模块 */}
      <section className="border-t bg-muted/20 py-16 md:py-20">
        <div className="container">
          <div className="mx-auto max-w-2xl text-center mb-12">
            <h2 className="text-3xl font-bold tracking-tight">4 大核心模块</h2>
            <p className="mt-3 text-muted-foreground">
              覆盖大厂面试全部考点
            </p>
          </div>
          <div className="mx-auto max-w-5xl grid gap-6 sm:grid-cols-2">
            {modules.map((mod) => (
              <Link key={mod.slug} href={`/paths/${mod.slug}`}>
                <Card className="h-full transition-all hover:shadow-md hover:-translate-y-1">
                  <CardHeader>
                    <div className="flex items-center justify-between mb-2">
                      <div className={`p-2.5 rounded-xl ${mod.bgColor}`}>
                        <mod.icon className={`h-6 w-6 ${mod.color}`} />
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge variant="outline">{mod.level}</Badge>
                        <Badge variant="secondary">{mod.hours}h</Badge>
                      </div>
                    </div>
                    <CardTitle className="text-xl">{mod.title}</CardTitle>
                    <CardDescription>{mod.description}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {mod.topics.map((topic) => (
                        <Badge key={topic} variant="secondary" className="text-xs">
                          {topic}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* 学习统计 */}
      <section className="container py-16">
        <div className="mx-auto max-w-4xl">
          <Card className="bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 border-0">
            <CardContent className="p-8">
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 text-center">
                <div>
                  <p className="text-3xl font-bold text-blue-600">{stats.pathsCount}</p>
                  <p className="text-sm text-muted-foreground mt-1">学习模块</p>
                </div>
                <div>
                  <p className="text-3xl font-bold text-purple-600">{stats.coursesCount}</p>
                  <p className="text-sm text-muted-foreground mt-1">课程</p>
                </div>
                <div>
                  <p className="text-3xl font-bold text-emerald-600">{stats.questionsCount}</p>
                  <p className="text-sm text-muted-foreground mt-1">面试题</p>
                </div>
                <div>
                  <p className="text-3xl font-bold text-amber-600">{stats.projectsCount}</p>
                  <p className="text-sm text-muted-foreground mt-1">项目作品</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* CTA */}
      <section className="border-t bg-muted/20 py-16 md:py-20">
        <div className="container text-center">
          <h2 className="text-3xl font-bold tracking-tight">准备好开始了？</h2>
          <p className="mt-3 text-muted-foreground max-w-lg mx-auto">
            加入 1000+ 工程师的行列，系统化掌握 LLM 应用开发
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <Button size="lg" className="h-12 px-8" asChild>
              <Link href="/mock-interview">
                <Zap className="mr-2 h-5 w-5" />
                立即开始
              </Link>
            </Button>
            <Button size="lg" variant="outline" className="h-12 px-8" asChild>
              <Link href="/interview">浏览题库</Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
}
