import styled from "@emotion/styled";
import { useState } from "react";

import ProgressBar from "./ProgressBar";

export default function HomeBase({ freeUnits }: { freeUnits: number }) {
  const [supply, setSupply] = useState(2);
  const [workers, setWorkers] = useState(0);

  function update(increment: number, limit: number) {
    setSupply((p) => Math.min(p + increment, limit));
  }

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
          update(2, 50);
        }}
      />
      <Text>ermf: {supply}</Text>
      <Text>glorps: {freeUnits}</Text>
    </Container>
  );
}

const Container = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: "5rem",
  height: "5rem",
  backgroundColor: "#282",
  outline: "2px solid #050",
});

const Text = styled.p({
  userSelect: "none",
  fontWeight: "bold",
  margin: 0,
});
