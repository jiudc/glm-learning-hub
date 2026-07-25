"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { supabase } from "@/lib/supabase";
import { Loader2 } from "lucide-react";

export function NoteForm() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({
    title: "",
    slug: "",
    content: "",
    excerpt: "",
    tags: "",
    category: "",
    is_published: false,
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));

    // Auto-generate slug from title
    if (name === "title" && !form.slug) {
      const slug = value
        .toLowerCase()
        .replace(/[^\w\s-]/g, "")
        .replace(/\s+/g, "-")
        .slice(0, 50);
      setForm((prev) => ({ ...prev, slug }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { error } = await supabase.from("notes").insert({
        title: form.title,
        slug: form.slug || form.title.toLowerCase().replace(/\s+/g, "-"),
        content: form.content,
        excerpt: form.excerpt || form.content.slice(0, 150),
        tags: form.tags
          .split(",")
          .map((t) => t.trim())
          .filter(Boolean),
        category: form.category || null,
        is_published: form.is_published,
      });

      if (error) throw error;

      // Reset form and refresh
      setForm({
        title: "",
        slug: "",
        content: "",
        excerpt: "",
        tags: "",
        category: "",
        is_published: false,
      });
      router.refresh();
    } catch (err) {
      alert("创建失败: " + (err as Error).message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card>
      <CardContent className="pt-6">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <Label htmlFor="title">标题 *</Label>
            <Input
              id="title"
              name="title"
              value={form.title}
              onChange={handleChange}
              placeholder="笔记标题"
              required
            />
          </div>

          <div>
            <Label htmlFor="slug">Slug</Label>
            <Input
              id="slug"
              name="slug"
              value={form.slug}
              onChange={handleChange}
              placeholder="url-friendly-name"
            />
          </div>

          <div>
            <Label htmlFor="content">内容 (Markdown) *</Label>
            <Textarea
              id="content"
              name="content"
              value={form.content}
              onChange={handleChange}
              placeholder="# 标题&#10;&#10;笔记内容..."
              rows={8}
              required
            />
          </div>

          <div>
            <Label htmlFor="excerpt">摘要</Label>
            <Textarea
              id="excerpt"
              name="excerpt"
              value={form.excerpt}
              onChange={handleChange}
              placeholder="简短描述（可选，默认取内容前150字）"
              rows={2}
            />
          </div>

          <div>
            <Label htmlFor="tags">标签（逗号分隔）</Label>
            <Input
              id="tags"
              name="tags"
              value={form.tags}
              onChange={handleChange}
              placeholder="GLM, API, 微调"
            />
          </div>

          <div>
            <Label htmlFor="category">分类</Label>
            <Input
              id="category"
              name="category"
              value={form.category}
              onChange={handleChange}
              placeholder="如：基础 / API / Agent"
            />
          </div>

          <div className="flex items-center gap-2">
            <Switch
              id="is_published"
              checked={form.is_published}
              onCheckedChange={(checked) =>
                setForm((prev) => ({ ...prev, is_published: checked }))
              }
            />
            <Label htmlFor="is_published">立即发布</Label>
          </div>

          <Button type="submit" disabled={loading} className="w-full">
            {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
            创建笔记
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
