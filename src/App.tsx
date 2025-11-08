import styled from "@emotion/styled";
import Plot from "./components/Plot";
import BasePlot from "./components/BasePlot";
import { useEffect, useState } from "react";

export default function App() {
  // const [maxWorkers, setMaxWorkers] = useState(10); // max units that can be allocated, will be increased by upgrades
  const maxWorkers = 25;
  const totalWorkers = 25;
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

  type GridCell = {
    id: number;
    x: number;
    y: number;
    hasPlot: boolean;
    isBase: boolean;
  };

  const [grid, setGrid] = useState<GridCell[]>(() => {
    const cells: GridCell[] = [];
    const size = 3; // starting 3x3 grid
    let id = 0;
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        cells.push({ id: id++, x, y, hasPlot: false, isBase: false });
      }
    }
    cells[4].isBase = true; // start with a base in the center
    cells[4].hasPlot = true;

    return cells;
  });

  const handleCellClick = (cell: GridCell) => {
    setGrid((prev) =>
      prev.map((c) =>
        c.id === cell.id
          ? { ...c, hasPlot: true, isBase: false } // spawn a plot
          : c
      )
    );
  };

  return (
    <Container>
      <GridWrapper>
        {grid.map((cell) =>
          cell.hasPlot ? (
            cell.isBase ? (
              <BasePlot
                key={cell.id}
                freeUnits={freeWorkers}
                resConsumer={updateResources}
                totalWorkers={totalWorkers}
                resources={resources}
              />
            ) : (
              <Plot
                key={cell.id}
                onClick={handlePlotClick}
                freeUnits={freeWorkers}
                controllPressed={controlPressed}
                resProducer={updateResources}
              />
            )
          ) : (
            <EmptyCell key={cell.id} onClick={() => handleCellClick(cell)}>
              +
            </EmptyCell>
          )
        )}
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

const EmptyCell = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: "5rem",
  height: "5rem",
  backgroundColor: "#333",
  outline: "1px dashed green",
});
