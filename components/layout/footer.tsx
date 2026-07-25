import { BookOpen } from "lucide-react";

export function Footer() {
  return (
    <footer className="border-t bg-muted/20">
      <div className="container py-8">
        <div className="flex flex-col items-center justify-between gap-6 md:flex-row">
          <div className="flex items-center gap-3">
            <BookOpen className="h-5 w-5 text-blue-600" />
            <div>
              <p className="font-semibold text-sm">GLM Learning Hub</p>
              <p className="text-xs text-muted-foreground">
                大模型应用工程师进阶平台
              </p>
            </div>
          </div>
          <div className="flex items-center gap-6 text-sm text-muted-foreground">
            <a href="/about" className="hover:text-foreground transition-colors">
              关于
            </a>
            <a
              href="https://github.com/THUDM"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              THUDM
            </a>
            <a
              href="https://github.com/jiudc/glm-learning-hub"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              GitHub
            </a>
          </div>
        </div>
        <div className="mt-6 pt-6 border-t text-center text-xs text-muted-foreground">
          © {new Date().getFullYear()} GLM Learning Hub · Built with Next.js & Supabase
        </div>
      </div>
    </footer>
  );
}
