import { supabase } from "@/lib/supabase";
import { notFound } from "next/navigation";
import Link from "next/link";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Clock, BookOpen, ChevronRight } from "lucide-react";
import type { LearningPath, Course } from "@/types/database";

async function getPath(slug: string): Promise<LearningPath | null> {
  const { data, error } = await supabase
    .from("learning_paths")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error || !data) return null;
  return data;
}

async function getCourses(pathId: string): Promise<Course[]> {
  const { data, error } = await supabase
    .from("courses")
    .select("*")
    .eq("path_id", pathId)
    .order("sort_order");

  if (error || !data) return [];
  return data;
}

interface Props {
  params: Promise<{ slug: string }>;
}

export default async function PathDetailPage({ params }: Props) {
  const { slug } = await params;
  const path = await getPath(slug);

  if (!path) notFound();

  const courses = await getCourses(path.id);

  return (
    <div className="container py-12 md:py-16">
      <div className="mx-auto max-w-3xl">
        <Button variant="ghost" size="sm" asChild className="-ml-3 mb-6">
          <Link href="/paths">
            <ArrowLeft className="mr-2 h-4 w-4" />
            返回学习路径
          </Link>
        </Button>

        <header className="mb-10">
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="secondary">{path.category}</Badge>
            <Badge variant="outline">{path.difficulty}</Badge>
            {path.estimated_hours && (
              <Badge variant="outline">
                <Clock className="mr-1 h-3 w-3" />
                {path.estimated_hours}h
              </Badge>
            )}
          </div>
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            {path.title}
          </h1>
          <p className="mt-3 text-muted-foreground">{path.description}</p>
        </header>

        {courses.length === 0 ? (
          <div className="text-center py-12 text-muted-foreground">
            <p>暂无课程数据</p>
          </div>
        ) : (
          <div className="space-y-4">
            <h2 className="text-xl font-semibold flex items-center gap-2">
              <BookOpen className="h-5 w-5" />
              课程列表 ({courses.length})
            </h2>
            {courses.map((course) => (
              <Card key={course.id} className="transition-shadow hover:shadow-md">
                <CardHeader className="pb-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <Link href={`/courses/${course.slug}`}>
                        <CardTitle className="text-lg hover:text-blue-600 transition-colors">
                          {course.title}
                        </CardTitle>
                      </Link>
                      <CardDescription className="mt-1">
                        {course.description}
                      </CardDescription>
                    </div>
                    <ChevronRight className="h-5 w-5 text-muted-foreground shrink-0" />
                  </div>
                </CardHeader>
                <CardContent className="pt-0">
                  <Button variant="ghost" size="sm" asChild>
                    <Link href={`/courses/${course.slug}`}>
                      开始学习
                      <ChevronRight className="ml-1 h-3 w-3" />
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
