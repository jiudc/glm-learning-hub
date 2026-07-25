import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { BookOpen, Database, Globe, Heart } from "lucide-react";

const techStack = [
  { name: "Next.js 14+", desc: "React 全栈框架 (App Router)", category: "前端" },
  { name: "TypeScript", desc: "类型安全", category: "前端" },
  { name: "TailwindCSS", desc: "原子化 CSS", category: "前端" },
  { name: "shadcn/ui", desc: "开源组件库", category: "前端" },
  { name: "Supabase", desc: "开源 Firebase 替代 (PostgreSQL)", category: "后端" },
  { name: "Vercel", desc: "前端部署平台", category: "部署" },
];

const resources = [
  { label: "智谱AI官网", url: "https://zhipuai.cn" },
  { label: "THUDM GitHub", url: "https://github.com/THUDM" },
  { label: "智谱学习中心", url: "https://learn.zhenguiren.cn/courses" },
  { label: "Bigmodel 开放平台", url: "https://bigmodel.cn" },
  { label: "z.ai", url: "https://z.ai" },
];

export default function AboutPage() {
  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            关于本站
          </h1>
          <p className="mt-4 text-muted-foreground">
            智谱AI GLM 系列开源模型的个人学习知识库
          </p>
        </div>

        {/* Intro */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BookOpen className="h-5 w-5 text-blue-600" />
              这是什么？
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 text-muted-foreground">
            <p>
              GLM Learning Hub 是一个个人学习知识库网站，用于整理和追踪智谱AI（Zhipu AI）GLM
              系列开源技术的学习内容。
            </p>
            <p>
              智谱AI 源自清华大学 THUDM
              实验室，是国内大模型开源最积极的团队之一。其 GLM 系列模型在开源社区具有重要影响力。
            </p>
            <p>本站包含以下核心模块：</p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>
                <strong className="text-foreground">学习路径</strong>
                — 从 GLM 入门到 Agent 开发的系统化路线
              </li>
              <li>
                <strong className="text-foreground">资源导航</strong>
                — 官方文档、GitHub、教程、论文一站式导航
              </li>
              <li>
                <strong className="text-foreground">学习笔记</strong>
                — 个人学习心得、代码片段、踩坑记录
              </li>
              <li>
                <strong className="text-foreground">进度追踪</strong>
                — 可视化学习进度
              </li>
            </ul>
          </CardContent>
        </Card>

        {/* Tech Stack */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Database className="h-5 w-5 text-green-600" />
              技术栈
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid gap-3 sm:grid-cols-2">
              {techStack.map((tech) => (
                <div
                  key={tech.name}
                  className="flex items-center justify-between rounded-lg border p-3"
                >
                  <div>
                    <p className="font-medium">{tech.name}</p>
                    <p className="text-sm text-muted-foreground">{tech.desc}</p>
                  </div>
                  <span className="text-xs text-muted-foreground bg-muted px-2 py-1 rounded">
                    {tech.category}
                  </span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Resources */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Globe className="h-5 w-5 text-purple-600" />
              推荐资源
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {resources.map((r) => (
                <a
                  key={r.url}
                  href={r.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-between rounded-lg border p-3 hover:bg-muted/50 transition-colors"
                >
                  <span className="font-medium">{r.label}</span>
                  <span className="text-xs text-blue-600">访问 →</span>
                </a>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Footer */}
        <div className="text-center text-sm text-muted-foreground py-8">
          <p className="flex items-center justify-center gap-1">
            用 <Heart className="h-4 w-4 text-red-500" /> 和 Next.js 构建
          </p>
          <p className="mt-2">
            © {new Date().getFullYear()} GLM Learning Hub
          </p>
        </div>
      </div>
    </div>
  );
}
