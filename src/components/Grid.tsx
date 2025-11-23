import styled from "@emotion/styled";
import { useGame } from "../context/GameContext";
import Plot from "./Plot";
import BasePlot from "./BasePlot";
import type { GridCell } from "../types";
import { theme } from "../theme";

export default function Grid() {
  const { grid, setGrid } = useGame();

  const handleCellClick = (cell: GridCell) => {
    setGrid((prev) =>
      prev.map((c) =>
        c.id === cell.id
          ? { ...c, hasPlot: true } // spawn a plot
          : c
      )
    );
  };

  return (
    <GridWrapper>
      {grid.map((cell) =>
        cell.hasPlot ? (
          cell.isBase ? (
            <BasePlot key={cell.id} />
          ) : (
            <Plot key={cell.id} />
          )
        ) : (
          <EmptyCell key={cell.id} onClick={() => handleCellClick(cell)}>
            +
          </EmptyCell>
        )
      )}
    </GridWrapper>
  );
}

const GridWrapper = styled.div({
  display: "grid",
  gridTemplateColumns: "repeat(3, 1fr)", // Creates 3 equal columns
  gap: theme.spacing.unit,
});

const EmptyCell = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: theme.spacing.plotSize,
  height: theme.spacing.plotSize,
  backgroundColor: theme.colors.plot.empty,
  outline: `1px dashed ${theme.colors.plot.emptyOutline}`,
  color: theme.colors.text,
  cursor: "pointer",
  "&:hover": {
    opacity: 0.8,
  },
});
