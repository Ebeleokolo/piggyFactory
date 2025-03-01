import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import * as dotenv from "dotenv";

dotenv.config();

const PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY || "";
const SEPOLIA_RPC_URL = process.env.ALCHEMY_SEPOLIA_API_KEY_URL || "";
const BASE_SEPOLIA_RPC_URL = process.env.BASE_SEPOLIA_RPC_URL || "https://sepolia.base.org";
const BASE_API_KEY = process.env.BASE_API_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    "base-sepolia": {
      url: BASE_SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 84532
    },
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 11155111
    },
  },
  etherscan: {
    apiKey: {
        "base-sepolia": process.env.BASE_API_KEY || ""
    },
    customChains: [
        {
            network: "base-sepolia",
            chainId: 84532,
            urls: {
                apiURL: "https://api-sepolia.basescan.org/api",
                browserURL: "https://sepolia.basescan.org"
            }
        }
    ]
  },
  sourcify: {
    enabled: false,
  },
 // typechain: {
 //   outDir: "typechain-types",
 //   target: "ethers-v5",
 // },
};

export default config;
