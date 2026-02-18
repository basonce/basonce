import { createConfig, http } from 'wagmi';
import { bscTestnet, polygonMumbai, bsc, polygon } from 'wagmi/chains';
import { injected, walletConnect } from 'wagmi/connectors';

const projectId = 'EARNQUEST_WALLET_CONNECT_ID';

export const config = createConfig({
  chains: [bscTestnet, polygonMumbai, bsc, polygon],
  connectors: [
    injected(),
    walletConnect({
      projectId,
      showQrModal: true
    }),
  ],
  transports: {
    [bscTestnet.id]: http('https://data-seed-prebsc-1-s1.binance.org:8545'),
    [polygonMumbai.id]: http('https://rpc-mumbai.maticvigil.com'),
    [bsc.id]: http('https://bsc-dataseed1.binance.org'),
    [polygon.id]: http('https://polygon-rpc.com'),
  },
});
