import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  type ReactNode,
} from "react";
import type { GridCell } from "../types";

interface GameState {
  maxWorkers: number;
  totalWorkers: number;
  freeWorkers: number;
  resources: number;
  grid: GridCell[];
  controlPressed: boolean;
  setFreeWorkers: (workers: number) => void;
  updateResources: (amount: number) => void;
  setGrid: React.Dispatch<React.SetStateAction<GridCell[]>>;
}

const GameContext = createContext<GameState | undefined>(undefined);

export const useGame = () => {
  const context = useContext(GameContext);
  if (!context) {
    throw new Error("useGame must be used within a GameProvider");
  }
  return context;
};

export const GameProvider = ({ children }: { children: ReactNode }) => {
  const maxWorkers = 25;
  const totalWorkers = 25;
  const [freeWorkers, setFreeWorkers] = useState(totalWorkers);
  const [resources, setResources] = useState(0);
  const [controlPressed, setControlPressed] = useState(false);

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

  const updateResources = (res: number) => {
    setResources((prev) => prev + res);
  };

  const value = {
    maxWorkers,
    totalWorkers,
    freeWorkers,
    resources,
    grid,
    controlPressed,
    setFreeWorkers,
    updateResources,
    setGrid,
  };

  return <GameContext.Provider value={value}>{children}</GameContext.Provider>;
};
