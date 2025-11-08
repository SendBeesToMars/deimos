import styled from "@emotion/styled";
import { useState } from "react";

import ProgressBar from "./ProgressBar";

export default function Plot({
  onClick,
  freeUnits,
  controllPressed = false,
  resProducer,
}: {
  onClick: (event: React.MouseEvent<HTMLElement>, change: number) => void;
  freeUnits: number;
  controllPressed: boolean;
  resProducer: (res: number) => void;
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
    const increment = controllPressed ? 5 : 1;
    if (event.type === "click") {
      // left click
      // increases the amount of units assigned to this plot if there are free units
      if (freeUnits <= 0) return;
      const increase =
        increment > freeUnits ? workers + freeUnits : workers + increment;
      setWorkers(increase);
      onClick(event, increment);
    } else if (event.type === "contextmenu") {
      // right click
      if (workers <= 0) return;
      const decrease = workers - (increment > workers ? workers : increment);
      setWorkers(decrease);
      onClick(event, increment > workers ? workers : increment);
    }
  }

  return (
    <PlotContainer
      onClick={(e) => handleClick(e)}
      onContextMenu={(e) => handleClick(e)}
    >
      <ProgressBar
        onComplete={() => {
          resProducer(supply ? Math.min(workers, supply) : 0);
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
