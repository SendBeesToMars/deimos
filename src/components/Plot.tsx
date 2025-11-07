import styled from '@emotion/styled'
import { useEffect, useState } from 'react';
import type { Dispatch, SetStateAction } from 'react';

export default function Plot() {
  const [resources, setResources] = useState(10);
  const [pop, setPop] = useState(0);

  const resourceCap = 100;

  useEffect(() => {
    const interval = setInterval(() => {
      // population cap
      if (resources < resourceCap) {
        setResources((prev) => Math.round(prev * 2.2));
      } else {
        setResources((prev) => Math.round(prev * 0.9));
      }
    }, 1000); // Increment resources every second

    // stop resource regen when resouces are depleted
    if (resources <= 0)
      clearInterval(interval)

    return () => clearInterval(interval); // Cleanup on unmount
  }, [resources]);

  return (
    <PlotContainer onClick={() => {
      console.log("xd");
      setPop(pop + 1);
    }}>
      <ProgressBar setResource={setResources} />
      <Text>ermf: {resources}</Text>
      <Text>glorps: {pop}</Text>
    </PlotContainer>
  )
}

function ProgressBar({ setResource }: { setResource: Dispatch<SetStateAction<number>> }) {
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    // start incrementing every second
    const interval = setInterval(() => {
      setProgress((prev) => {
        const next = prev + 0.5
        if (next > 100) {
          // call the passed setter to add resources
          setResource((prev) => prev + 10);
          return 0;
        }
        return next;
      })
    }, 1000)

    return () => clearInterval(interval)
  }, [setResource])

  return (
    <ProgressBarContainer max={100} value={progress} />
  )
}

const PlotContainer = styled.div({
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  width: "5rem",
  height: "5rem",
  backgroundColor: "lightgray",
  outline: "2px solid gray",
})

const Text = styled.p({
  userSelect: 'none',
  fontWeight: 'bold',
  margin: 0,
})

const ProgressBarContainer = styled.progress({
  width: '80%',
});