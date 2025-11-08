import styled from "@emotion/styled";
import Plot from "./components/Plot";
import HomeBase from "./components/HomeBase";
import { useEffect, useState } from "react";

export default function App() {
  // const [maxWorkers, setMaxWorkers] = useState(10); // max units that can be allocated, will be increased by upgrades
  const maxWorkers = 25;
  const totalWorkers = 20;
  const [freeWorkers, setFreeWorkers] = useState(totalWorkers);
  const [resources, setResources] = useState(0);
  const [controlPressed, setControlPressed] = useState(false);

  // controll key press detection
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Control") {
        setControlPressed(true);
      }
    };
    const handleKeyUp = (e: KeyboardEvent) => {
      if (e.key === "Control") {
        setControlPressed(false);
      }
    };
    document.addEventListener("keydown", handleKeyDown);
    document.addEventListener("keyup", handleKeyUp);

    return () => {
      document.removeEventListener("keydown", handleKeyDown);
      document.removeEventListener("keyup", handleKeyUp);
    };
  }, []);

  const handlePlotClick = (
    event: React.MouseEvent<HTMLElement>,
    change: number
  ) => {
    if (event.type === "click") {
      // left click
      // decrease available units
      if (freeWorkers <= maxWorkers) {
        setFreeWorkers(freeWorkers - change < 0 ? 0 : freeWorkers - change);
      }
    } else if (event.type === "contextmenu") {
      setFreeWorkers(
        freeWorkers + change > totalWorkers
          ? totalWorkers
          : freeWorkers + change
      );
    }
  };

  const updateResources = (res: number) => {
    setResources((prev) => prev + res);
  };

  return (
    <Container>
      <GridWrapper>
        <Plot
          onClick={handlePlotClick}
          freeUnits={freeWorkers}
          controllPressed={controlPressed}
          resProducer={updateResources}
        />
        <HomeBase
          freeUnits={freeWorkers}
          resources={resources}
          resConsumer={updateResources}
          totalWorkers={totalWorkers}
        />
        <Plot
          onClick={handlePlotClick}
          freeUnits={freeWorkers}
          controllPressed={controlPressed}
          resProducer={updateResources}
        />
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
