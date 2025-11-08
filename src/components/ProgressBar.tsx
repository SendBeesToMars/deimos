import styled from "@emotion/styled";
import { useEffect, useState } from "react";

export default function ProgressBar({
  onComplete,
  speed = 100,
}: {
  onComplete: () => void;
  speed?: number;
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
    }, speed);

    return () => clearInterval(interval);
  }, [speed]);

  // when a sweep completes, notify parent in an effect (safe — runs after render)
  useEffect(() => {
    if (!completed) return;
    onComplete();
    setCompleted(false);
  }, [completed, onComplete]);

  return <ProgressBarContainer max={100} value={progress} />;
}

const ProgressBarContainer = styled.progress({
  width: "80%",
});
