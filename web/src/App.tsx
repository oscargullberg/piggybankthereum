import { ConnectButton } from '@rainbow-me/rainbowkit';

function App() {

  return (
    <div>
      <header style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "1rem 1.5rem",
        background: "#262c36",
        position: "sticky",
        top: 0
      }}
      >
        <h1>PiggyBank</h1>
        <ConnectButton />
      </header>

      <main>
      </main>
    </div>
  );
}

export default App;
