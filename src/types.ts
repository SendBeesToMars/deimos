export type GridCell = {
  id: number;
  x: number;
  y: number;
  hasPlot: boolean;
  isBase: boolean;
};

export type PlotType = "base" | "standard";
