"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Lightbulb, Eye, EyeOff, ChevronDown } from "lucide-react";

interface Props {
  hint?: string | null;
  answer: string;
}

export function ProgressiveAnswer({ hint, answer }: Props) {
  const [stage, setStage] = useState<"think" | "hint" | "answer">("think");

  const renderMarkdown = (text: string) => {
    return text.split("\n").map((line, i) => {
      if (line.startsWith("# "))
        return (
          <h1 key={i} className="text-2xl font-bold mt-5 mb-3">
            {line.slice(2)}
          </h1>
        );
      if (line.startsWith("## "))
        return (
          <h2 key={i} className="text-xl font-semibold mt-4 mb-2">
            {line.slice(3)}
          </h2>
        );
      if (line.startsWith("### "))
        return (
          <h3 key={i} className="text-lg font-semibold mt-3 mb-2">
            {line.slice(4)}
          </h3>
        );
      if (line.startsWith("- "))
        return (
          <li key={i} className="ml-4 text-foreground/80 list-disc">
            {line.slice(2)}
          </li>
        );
      if (line.startsWith("| "))
        return (
          <p key={i} className="font-mono text-sm text-foreground/80">
            {line}
          </p>
        );
      if (line.startsWith("```"))
        return (
          <div
            key={i}
            className="rounded-lg bg-muted p-4 my-4 font-mono text-sm overflow-x-auto"
          />
        );
      if (line.trim() === "") return <br key={i} />;
      return (
        <p key={i} className="text-foreground/80 leading-relaxed">
          {line}
        </p>
      );
    });
  };

  return (
    <div className="space-y-4">
      {/* 阶段指示器 */}
      <div className="flex items-center gap-2">
        <div
          className={`h-2 flex-1 rounded-full transition-colors ${
            stage !== "think" ? "bg-blue-500" : "bg-muted"
          }`}
        />
        <div
          className={`h-2 flex-1 rounded-full transition-colors ${
            stage === "answer" ? "bg-blue-500" : "bg-muted"
          }`}
        />
      </div>

      {/* 思考阶段 */}
      {stage === "think" && (
        <div className="text-center py-8 space-y-4">
          <p className="text-muted-foreground">
            💡 先自己思考一下，再看提示和答案
          </p>
          <Button onClick={() => setStage("hint")} variant="outline">
            <Lightbulb className="mr-2 h-4 w-4" />
            查看提示
          </Button>
        </div>
      )}

      {/* 提示阶段 */}
      {stage === "hint" && (
        <div className="space-y-4">
          <div className="rounded-lg border bg-yellow-50 dark:bg-yellow-950/20 p-4">
            <div className="flex items-center gap-2 mb-2">
              <Lightbulb className="h-4 w-4 text-yellow-600" />
              <span className="font-medium text-sm">提示</span>
            </div>
            <p className="text-sm text-muted-foreground">
              {hint || "先思考这个问题涉及哪些核心模块？每个模块的技术选型是什么？"}
            </p>
          </div>
          <Button onClick={() => setStage("answer")} className="w-full">
            <Eye className="mr-2 h-4 w-4" />
            查看参考答案
          </Button>
        </div>
      )}

      {/* 答案阶段 */}
      {stage === "answer" && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold">参考答案</h3>
            <Button
              onClick={() => setStage("think")}
              variant="ghost"
              size="sm"
            >
              <EyeOff className="mr-2 h-4 w-4" />
              重新思考
            </Button>
          </div>
          <div className="rounded-lg border p-6 prose prose-neutral dark:prose-invert max-w-none">
            {renderMarkdown(answer)}
          </div>
        </div>
      )}
    </div>
  );
}
