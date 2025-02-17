import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    // for testnet
    // "lisk-sepolia": {
    //   url: process.env.LISK_RPC_URL!,
    //   accounts: [process.env.ACCOUNT_PRIVATE_KEY!],
    //   gasPrice: 1000000000,
    // },
    scrollSepolia: {
      url: "https://scroll-sepolia.g.alchemy.com/v2/yGouDJNdYc-mbzx5nfkfr6a_tF8X9U1M" || "",
      accounts:
        process.env.ACCOUNT_PRIVATE_KEY !== undefined ? [process.env.ACCOUNT_PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    // Use "123" as a placeholder, because Blockscout doesn't need a real API key, and Hardhat will complain if this property isn't set.
    apiKey: {
      "lisk-sepolia": "123",
      scrollSepolia: "123",
    },
    customChains: [
      {
        network: "lisk-sepolia",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api",
          browserURL: "https://sepolia-blockscout.lisk.com/",
        },
      },
      {
        network: 'scrollSepolia',
        chainId: 534351,
        urls: {
          apiURL: 'https://api-sepolia.scrollscan.com/api',
          browserURL: 'https://sepolia.scrollscan.com/',
        },
      },
    ],
  },
  sourcify: {
    enabled: false,
  },
};

export default config;