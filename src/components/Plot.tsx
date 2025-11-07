import styled from "@emotion/styled";
import { useState } from "react";

import ProgressBar from "./ProgressBar";

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
