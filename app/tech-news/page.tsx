import { supabase } from "@/lib/supabase";
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
  Newspaper,
  ExternalLink,
  Calendar,
  TrendingUp,
  Sparkles,
  Bot,
  Search,
  Cpu,
  Shield,
  Package,
} from "lucide-react";
import Link from "next/link";

async function getNews() {
  const { data, error } = await supabase
    .from("tech_news")
    .select("*")
    .order("is_featured", { ascending: false })
    .order("published_date", { ascending: false })
    .limit(20);

  if (error || !data) return [];
  return data;
}

const categoryConfig: Record<string, { label: string; icon: typeof Newspaper; color: string }> = {
  ai: { label: "AI 前沿", icon: Sparkles, color: "text-purple-600" },
  llm: { label: "大模型", icon: Bot, color: "text-blue-600" },
  agent: { label: "Agent", icon: Cpu, color: "text-green-600" },
  rag: { label: "RAG", icon: Search, color: "text-orange-600" },
  finetuning: { label: "微调", icon: TrendingUp, color: "text-pink-600" },
  deployment: { label: "部署", icon: Package, color: "text-cyan-600" },
  safety: { label: "安全", icon: Shield, color: "text-red-600" },
  product: { label: "产品", icon: Newspaper, color: "text-amber-600" },
};

export default async function TechNewsPage() {
  const news = await getNews();

  const featured = news.filter((n) => n.is_featured);
  const regular = news.filter((n) => !n.is_featured);

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-4xl">
        <div className="text-center mb-10">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            每日科技热点
          </h1>
          <p className="mt-3 text-muted-foreground">
            追踪 AI/LLM 领域最新动态，保持技术敏感度
          </p>
        </div>

        {news.length === 0 ? (
          <div className="text-center py-12 text-muted-foreground">
            <p>暂无新闻数据，请先在 Supabase 中执行 migration_v3.sql</p>
          </div>
        ) : (
          <>
            {/* 头条新闻 */}
            {featured.length > 0 && (
              <section className="mb-10">
                <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-red-500" />
                  今日热点
                </h2>
                <div className="grid gap-4 sm:grid-cols-2">
                  {featured.map((item) => {
                    const config = categoryConfig[item.category] || categoryConfig.ai;
                    const Icon = config.icon;
                    return (
                      <Card key={item.id} className="hover:shadow-md transition-shadow">
                        <CardHeader className="pb-3">
                          <div className="flex items-center justify-between mb-2">
                            <div className="flex items-center gap-2">
                              <Icon className={`h-4 w-4 ${config.color}`} />
                              <Badge variant="secondary" className="text-xs">
                                {config.label}
                              </Badge>
                            </div>
                            <Badge variant="destructive" className="text-xs">
                              热门
                            </Badge>
                          </div>
                          <CardTitle className="text-base">{item.title}</CardTitle>
                          <CardDescription className="text-sm line-clamp-2">
                            {item.summary}
                          </CardDescription>
                        </CardHeader>
                        <CardContent className="pt-0">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                              <Calendar className="h-3 w-3" />
                              {item.published_date}
                            </div>
                            {item.source_url && (
                              <a
                                href={item.source_url}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="text-xs text-blue-600 hover:underline flex items-center gap-1"
                              >
                                来源 <ExternalLink className="h-3 w-3" />
                              </a>
                            )}
                          </div>
                        </CardContent>
                      </Card>
                    );
                  })}
                </div>
              </section>
            )}

            {/* 更多新闻 */}
            {regular.length > 0 && (
              <section>
                <h2 className="text-xl font-semibold mb-4">更多动态</h2>
                <div className="space-y-3">
                  {regular.map((item) => {
                    const config = categoryConfig[item.category] || categoryConfig.ai;
                    const Icon = config.icon;
                    return (
                      <Card key={item.id} className="hover:shadow-sm transition-shadow">
                        <CardHeader className="py-3">
                          <div className="flex items-start justify-between gap-4">
                            <div className="min-w-0 flex-1">
                              <div className="flex items-center gap-2 mb-1">
                                <Icon className={`h-4 w-4 ${config.color}`} />
                                <Badge variant="outline" className="text-xs">
                                  {config.label}
                                </Badge>
                                <span className="text-xs text-muted-foreground">
                                  {item.published_date}
                                </span>
                              </div>
                              <CardTitle className="text-sm font-medium">
                                {item.title}
                              </CardTitle>
                              <CardDescription className="text-xs line-clamp-1 mt-1">
                                {item.summary}
                              </CardDescription>
                            </div>
                            {item.source_url && (
                              <a
                                href={item.source_url}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="shrink-0"
                              >
                                <Button variant="ghost" size="icon" className="h-8 w-8">
                                  <ExternalLink className="h-4 w-4" />
                                </Button>
                              </a>
                            )}
                          </div>
                        </CardHeader>
                      </Card>
                    );
                  })}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </div>
  );
}
