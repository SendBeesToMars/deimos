import styled from "@emotion/styled";
import Plot from "./components/Plot";
import HomeBase from "./components/HomeBase";
import { useState } from "react";

export default function App() {
  // const [maxUnits, setMaxUnits] = useState(10); // max units that can be allocated, will be increased by upgrades
  const maxUnits = 10;
  const [freeUnits, setFreeUnits] = useState(5);

  const handleClick = (e: React.MouseEvent<HTMLElement>) => {
    e.preventDefault();
    if (e.type === "click") {
      // left click
      // decrease available units
      if (freeUnits <= maxUnits) {
        setFreeUnits(Math.max(freeUnits - 1, 0));
        console.log("Left click");
      }
    } else if (e.type === "contextmenu") {
      setFreeUnits(Math.min(freeUnits + 1, maxUnits));
      console.log("Right click");
    }
  };

  return (
    <Container>
      <GridWrapper>
        <Plot onClick={handleClick} freeUnits={freeUnits} />
        <HomeBase freeUnits={freeUnits} />
      </GridWrapper>
    </Container>
  );
}

const Container = styled.div({
  // center content of this div to the center of the screen
  display: "flex",
  flexDirection: "row",
  justifyContent: "center",
  alignItems: "center",
  height: "100vh",
  width: "100vw",
});

const GridWrapper = styled.div({
  display: "grid",
  gridTemplateColumns: "repeat(3, 1fr)", // Creates 3 equal columns
});
