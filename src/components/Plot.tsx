import styled from "@emotion/styled";
import { useEffect, useState } from "react";

export default function Plot() {
  const [supply, setSupply] = useState(2);
  const [harvester, setHarvesters] = useState(0);

  function update(n: number, increment: number, limit: number, k: number) {
    // k controls the steepness of the falloff
    if (n == 1) return n;
    const d = n - limit;
    let decrement = d > 0 ? k * d * d : 0; // quadratic falloff
    if (n > limit && decrement >= n * increment) {
      decrement = n * increment - 2; // ensure at least 2 resource is gained
    }
    // console.log({ n, increment, decrement, ret: n * increment - decrement });
    return Math.ceil(n * increment - decrement);
  }

  return (
    <PlotContainer
      onClick={() => {
        setHarvesters(harvester + 1);
      }}
      onContextMenuCapture={(e) => {
        // right click
        e.preventDefault(); // prevent context menu
        setHarvesters(Math.max(harvester - 1, 0));
      }}
    >
      <ProgressBar
        resources={supply}
        onComplete={() =>
          setSupply((p) => Math.max(update(p, 1.2, 100, 0.01) - harvester, 0))
        }
      />
      <Text>ermf: {supply}</Text>
      <Text>glorps: {harvester}</Text>
    </PlotContainer>
  );
}

function ProgressBar({
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

const PlotContainer = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: "5rem",
  height: "5rem",
  backgroundColor: "#333",
  outline: "2px solid gray",
});

const Text = styled.p({
  userSelect: "none",
  fontWeight: "bold",
  margin: 0,
});

const ProgressBarContainer = styled.progress({
  width: "80%",
});
