import styled from "@emotion/styled";
import { useState } from "react";

import ProgressBar from "./ProgressBar";

export default function Plot({
  onClick,
  freeUnits,
}: {
  onClick: React.MouseEventHandler<HTMLElement>;
  freeUnits: number;
}) {
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
    // console.log({ n, increment, decrement, ret: n * increment - decrement });
    return Math.ceil(n * increment - decrement);
  }

  function handleClick(event: React.MouseEvent<HTMLElement>) {
    event.preventDefault();
    if (event.type === "click") {
      // left click
      // increases the amount of units assigned to this plot if there are free units
      if (freeUnits <= 0) return;
      setWorkers(workers + 1);
      onClick(event);
    } else if (event.type === "contextmenu") {
      // right click
      if (workers <= 0) return;
      setWorkers(workers - 1);
      onClick(event);
    }
  }

  return (
    <PlotContainer
      onClick={(e) => handleClick(e)}
      onContextMenu={(e) => handleClick(e)}
    >
      <ProgressBar
        onComplete={() =>
          setSupply(
            (p) => Math.max(update(p, 1.2, 100, 0.01) - workers, 0) // harvesters could have a multiplier
          )
        }
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
