import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Home } from "lucide-react";

export default function NotFound() {
  return (
    <div className="flex flex-1 flex-col items-center justify-center py-20">
      <div className="text-center">
        <p className="text-6xl font-bold text-muted-foreground">404</p>
        <h1 className="mt-4 text-2xl font-bold tracking-tight">页面未找到</h1>
        <p className="mt-2 text-muted-foreground">
          抱歉，你访问的页面不存在或已被移除。
        </p>
        <Button className="mt-6" asChild>
          <Link href="/">
            <Home className="mr-2 h-4 w-4" />
            返回首页
          </Link>
        </Button>
      </div>
    </div>
  );
}
