"use client";

import { useState, useMemo } from "react";
import Link from "next/link";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Search, Calendar } from "lucide-react";
import type { Note } from "@/types/database";

function formatDate(dateString: string) {
  return new Date(dateString).toLocaleDateString("zh-CN", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

interface Props {
  notes: Note[];
}

export function NotesList({ notes }: Props) {
  const [searchQuery, setSearchQuery] = useState("");

  const filteredNotes = useMemo(() => {
    if (!searchQuery.trim()) return notes;

    const query = searchQuery.toLowerCase();
    return notes.filter((note) => {
      const titleMatch = note.title.toLowerCase().includes(query);
      const excerptMatch = note.excerpt?.toLowerCase().includes(query);
      const tagMatch = note.tags?.some((tag) =>
        tag.toLowerCase().includes(query)
      );
      const categoryMatch = note.category?.toLowerCase().includes(query);
      return titleMatch || excerptMatch || tagMatch || categoryMatch;
    });
  }, [notes, searchQuery]);

  // Collect all unique tags for quick filters
  const allTags = useMemo(() => {
    const tagSet = new Set<string>();
    notes.forEach((note) => {
      note.tags?.forEach((tag) => tagSet.add(tag));
    });
    return Array.from(tagSet).sort();
  }, [notes]);

  return (
    <div className="mx-auto max-w-4xl">
      {/* Search Bar */}
      <div className="mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="搜索笔记标题、标签、内容..."
            className="pl-10"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        {searchQuery && (
          <p className="mt-2 text-sm text-muted-foreground">
            找到 {filteredNotes.length} 篇相关笔记
          </p>
        )}
      </div>

      {/* Quick tag filters */}
      {allTags.length > 0 && (
        <div className="mb-6 flex flex-wrap gap-2">
          {allTags.slice(0, 10).map((tag) => (
            <Badge
              key={tag}
              variant={searchQuery === tag ? "default" : "outline"}
              className="cursor-pointer text-xs"
              onClick={() =>
                setSearchQuery(searchQuery === tag ? "" : tag)
              }
            >
              {tag}
            </Badge>
          ))}
        </div>
      )}

      {/* Notes List */}
      {filteredNotes.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-muted-foreground">
            没有找到匹配的笔记
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredNotes.map((note) => (
            <Card key={note.id} className="transition-shadow hover:shadow-md">
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <Link href={`/notes/${note.slug}`}>
                      <CardTitle className="text-lg hover:text-blue-600 transition-colors">
                        {note.title}
                      </CardTitle>
                    </Link>
                    <CardDescription className="mt-1 line-clamp-2">
                      {note.excerpt || "暂无摘要"}
                    </CardDescription>
                  </div>
                  <div className="flex items-center gap-1 text-xs text-muted-foreground shrink-0">
                    <Calendar className="h-3 w-3" />
                    {formatDate(note.updated_at)}
                  </div>
                </div>
              </CardHeader>
              <CardContent className="pt-0">
                <div className="flex items-center gap-2">
                  {note.category && (
                    <Badge variant="secondary" className="text-xs">
                      {note.category}
                    </Badge>
                  )}
                  {note.tags?.slice(0, 4).map((tag) => (
                    <Badge key={tag} variant="outline" className="text-xs">
                      {tag}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
