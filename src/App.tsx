import styled from '@emotion/styled';
import Plot from './components/Plot';

export default function App() {
  return (
    <Container>
      <GridWrapper>
        <Plot />
      </GridWrapper>
    </Container>
  );
}

const Container = styled.div({
  // center content of this div to the center of the screen
  display: 'flex',
  flexDirection: 'row',
  justifyContent: 'center',
  alignItems: 'center',
  height: '100vh',
  width: '100vw',
});

const GridWrapper = styled.div({
  display: 'grid',
  gridTemplateColumns: 'repeat(3, 1fr)', // Creates 3 equal columns
});
