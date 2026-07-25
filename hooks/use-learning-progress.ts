"use client";

import { useState, useEffect, useCallback } from "react";

export type LearningStatus = "not_started" | "in_progress" | "completed";

interface LearningProgress {
  [questionId: string]: {
    status: LearningStatus;
    lastVisited: number;
    timeSpent: number; // seconds
    wrongCount: number;
  };
}

const STORAGE_KEY = "glm-learning-progress";

export function useLearningProgress() {
  const [progress, setProgress] = useState<LearningProgress>({});
  const [isLoaded, setIsLoaded] = useState(false);

  // 从 localStorage 加载
  useEffect(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved) {
        setProgress(JSON.parse(saved));
      }
    } catch (e) {
      console.error("Failed to load progress:", e);
    }
    setIsLoaded(true);
  }, []);

  // 保存到 localStorage
  const saveProgress = useCallback((newProgress: LearningProgress) => {
    setProgress(newProgress);
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(newProgress));
    } catch (e) {
      console.error("Failed to save progress:", e);
    }
  }, []);

  // 更新题目状态
  const updateStatus = useCallback(
    (questionId: string, status: LearningStatus) => {
      setProgress((prev) => {
        const newProgress = {
          ...prev,
          [questionId]: {
            ...prev[questionId],
            status,
            lastVisited: Date.now(),
            timeSpent: (prev[questionId]?.timeSpent || 0),
            wrongCount: prev[questionId]?.wrongCount || 0,
          },
        };
        try {
          localStorage.setItem(STORAGE_KEY, JSON.stringify(newProgress));
        } catch (e) {
          console.error("Failed to save:", e);
        }
        return newProgress;
      });
    },
    []
  );

  // 增加错误次数
  const markWrong = useCallback((questionId: string) => {
    setProgress((prev) => {
      const newProgress = {
        ...prev,
        [questionId]: {
          ...prev[questionId],
          status: "in_progress" as LearningStatus,
          lastVisited: Date.now(),
          wrongCount: (prev[questionId]?.wrongCount || 0) + 1,
          timeSpent: prev[questionId]?.timeSpent || 0,
        },
      };
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(newProgress));
      } catch (e) {
        console.error("Failed to save:", e);
      }
      return newProgress;
    });
  }, []);

  // 获取统计
  const getStats = useCallback(() => {
    const entries = Object.values(progress);
    return {
      total: entries.length,
      completed: entries.filter((e) => e.status === "completed").length,
      inProgress: entries.filter((e) => e.status === "in_progress").length,
      totalTime: entries.reduce((sum, e) => sum + e.timeSpent, 0),
      wrongCount: entries.filter((e) => e.wrongCount > 0).length,
    };
  }, [progress]);

  return {
    progress,
    isLoaded,
    updateStatus,
    markWrong,
    getStats,
  };
}
