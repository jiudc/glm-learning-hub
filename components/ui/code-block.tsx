"use client";

import { useEffect, useState } from "react";
import { codeToHtml } from "shiki";

interface Props {
  code: string;
  language?: string;
}

export function CodeBlock({ code, language = "typescript" }: Props) {
  const [html, setHtml] = useState<string>("");

  useEffect(() => {
    codeToHtml(code, {
      lang: language,
      theme: "github-dark",
    }).then(setHtml);
  }, [code, language]);

  if (!html) {
    return <pre className="rounded-lg bg-muted p-4 overflow-x-auto"><code>{code}</code></pre>;
  }

  return (
    <div
      className="rounded-lg overflow-x-auto text-sm [&>shiki]:p-4 [&>shiki]:rounded-lg"
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}
