import styled from "@emotion/styled";
import { useEffect, useState } from "react";

export default function Plot() {
  const [supply, setSupply] = useState(10);
  const [harvester, setHarvesters] = useState(0);

  return (
    <PlotContainer
      onClick={() => {
        console.log("xd");
        setHarvesters(harvester + 1);
      }}
    >
      <ProgressBar
        resources={supply}
        onComplete={() => setSupply((p) => Math.round(p * 2.2) - harvester)}
        onCap={() =>
          setSupply((p) =>
            Math.round(p * 0.9) - harvester <= 0
              ? 0
              : Math.round(p * 0.9) - harvester
          )
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
  onCap,
}: {
  resources: number;
  onComplete: () => void;
  onCap: () => void;
}) {
  const [progress, setProgress] = useState(0);
  const [completed, setCompleted] = useState(false);

  const resourceCap = 100;

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
    if (resources < resourceCap) onComplete();
    else onCap();
    setCompleted(false);
  }, [completed, resources, onComplete, onCap]);

  return <ProgressBarContainer max={100} value={progress} />;
}

const PlotContainer = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: "5rem",
  height: "5rem",
  backgroundColor: "lightgray",
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
