import styled from "@emotion/styled";
import { useEffect, useState } from "react";

export default function ProgressBar({
  resources,
  onComplete,
}: {
  resources: number;
  onComplete: () => void;
}) {
  const [progress, setProgress] = useState(0);
  const [completed, setCompleted] = useState(false);

  useEffect(() => {
    // sweep 0 -> 100 over ~1s (10 ticks of 100ms -> +10 each)
    const interval = setInterval(() => {
      setProgress((prev) => {
        const next = prev + 10;
        if (next >= 100) {
          setCompleted(true);
          return 0;
        }
        return next;
      });
    }, 100);

    return () => clearInterval(interval);
  }, []);

  // when a sweep completes, notify parent in an effect (safe — runs after render)
  useEffect(() => {
    if (!completed) return;
    onComplete();
    setCompleted(false);
  }, [completed, resources, onComplete]);

  return <ProgressBarContainer max={100} value={progress} />;
}

const ProgressBarContainer = styled.progress({
  width: "80%",
});
