import styled from "@emotion/styled";
import { useState } from "react";
import { useGame } from "../context/GameContext";
import ProgressBar from "./ProgressBar";
import { theme } from "../theme";

export default function Plot() {
  const { freeWorkers, setFreeWorkers, controlPressed, updateResources } =
    useGame();
  const [supply, setSupply] = useState(2);
  const [workers, setWorkers] = useState(0);

  function update(n: number, increment: number, limit: number, k: number) {
    // k controls the steepness of the falloff
    if (n == 1) return n;
    const d = n - limit;
    let decrement = d > 0 ? k * d * d : 0; // quadratic falloff
    if (n > limit && decrement >= n * increment) {
      decrement = n * increment - 2; // ensure at least 2 resource is gained
    }
    return Math.ceil(n * increment - decrement);
  }

  function handleClick(event: React.MouseEvent<HTMLElement>) {
    event.preventDefault();
    const increment = controlPressed ? 5 : 1;

    if (event.type === "click") {
      // left click
      // increases the amount of units assigned to this plot if there are free units
      if (freeWorkers <= 0) return;

      // Calculate how many workers we can actually add
      const actualIncrement = Math.min(increment, freeWorkers);

      setWorkers((prev) => prev + actualIncrement);
      setFreeWorkers(freeWorkers - actualIncrement);
    } else if (event.type === "contextmenu") {
      // right click
      if (workers <= 0) return;

      // Calculate how many workers we can actually remove
      const actualDecrement = Math.min(increment, workers);

      setWorkers((prev) => prev - actualDecrement);
      setFreeWorkers(freeWorkers + actualDecrement);
    }
  }

  return (
    <PlotContainer
      onClick={(e) => handleClick(e)}
      onContextMenu={(e) => handleClick(e)}
    >
      <ProgressBar
        onComplete={() => {
          updateResources(supply ? Math.min(workers, supply) : 0);
          return setSupply(
            (p) => Math.max(update(p, 1.2, 100, 0.01) - workers, 0) // harvesters could have a multiplier
          );
        }}
      />
      <Text>ermf: {supply}</Text>
      <Text>glorps: {workers}</Text>
    </PlotContainer>
  );
}

const PlotContainer = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: theme.spacing.plotSize,
  height: theme.spacing.plotSize,
  backgroundColor: theme.colors.plot.standard,
  outline: `2px solid ${theme.colors.plot.standardOutline}`,
  color: theme.colors.text,
});

const Text = styled.p({
  userSelect: "none",
  fontWeight: "bold",
  margin: 0,
  fontSize: "0.8rem",
});
