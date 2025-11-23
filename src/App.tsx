import styled from "@emotion/styled";
import { GameProvider } from "./context/GameContext";
import Grid from "./components/Grid";
import { theme } from "./theme";

export default function App() {
  return (
    <GameProvider>
      <Container>
        <Grid />
      </Container>
    </GameProvider>
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
  backgroundColor: theme.colors.background,
  color: theme.colors.text,
});
