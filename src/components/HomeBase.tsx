import styled from "@emotion/styled";
import { useState } from "react";

import ProgressBar from "./ProgressBar";

export default function HomeBase({
  freeUnits,
  resources,
  resConsumer,
}: {
  freeUnits: number;
  resources: number;
  resConsumer: (res: number) => void;
}) {
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
          resConsumer(1);
        }}
        speed={1000}
      />
      <Text>ermf: {resources}</Text>
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
