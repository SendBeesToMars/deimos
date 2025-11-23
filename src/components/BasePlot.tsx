import styled from "@emotion/styled";
import { useState } from "react";
import { useGame } from "../context/GameContext";
import ProgressBar from "./ProgressBar";
import { theme } from "../theme";

export default function BasePlot() {
  const { freeWorkers, resources, updateResources, totalWorkers } = useGame();
  const [workers, setWorkers] = useState(0);

  return (
    <Container
      onClick={() => {
        setWorkers(workers + 1);
      }}
      onContextMenuCapture={(e) => {
        // right click
        e.preventDefault(); // prevent context menu
        setWorkers(Math.max(workers - 1, 0));
      }}
    >
      <ProgressBar
        onComplete={() => {
          updateResources(-totalWorkers);
        }}
        speed={500}
      />
      <Text>ermf: {resources}</Text>
      <Text>glorps: {freeWorkers}</Text>
    </Container>
  );
}

const Container = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: theme.spacing.plotSize,
  height: theme.spacing.plotSize,
  backgroundColor: theme.colors.plot.base,
  outline: `2px solid ${theme.colors.plot.baseOutline}`,
  color: theme.colors.text,
});

const Text = styled.p({
  userSelect: "none",
  fontWeight: "bold",
  margin: 0,
  fontSize: "0.8rem",
});
