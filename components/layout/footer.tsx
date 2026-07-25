import { BookOpen } from "lucide-react";

export function Footer() {
  return (
    <footer className="border-t bg-background">
      <div className="container py-6 flex flex-col items-center justify-between gap-4 md:flex-row">
        <div className="flex items-center gap-2">
          <BookOpen className="h-4 w-4 text-blue-600" />
          <p className="text-sm text-muted-foreground">
            GLM Learning Hub — 智谱AI学习知识库
          </p>
        </div>
        <p className="text-sm text-muted-foreground">
          Built with Next.js & Supabase ·{" "}
          <a
            href="https://github.com/THUDM"
            className="hover:text-foreground"
            target="_blank"
            rel="noopener noreferrer"
          >
            THUDM
          </a>{" "}
          开源驱动
        </p>
      </div>
    </footer>
  );
}
