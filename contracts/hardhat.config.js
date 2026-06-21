require("dotenv").config()
require("@nomicfoundation/hardhat-toolbox")
const accounts = process.env.DEPLOYER_PRIVATE_KEY ? [process.env.DEPLOYER_PRIVATE_KEY] : "remote"
module.exports = {
  solidity: {
    version: "0.8.34",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      evmVersion: "cancun"
    }
  },
  networks: {
    cgltchain: {
      url: process.env.CGLT_NODE_URL || "http://localhost:8545",
      chainId: 242626,
      accounts
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org",
      chainId: 56,
      accounts
    }
  },
  etherscan: {
    apiKey: process.env.BSCSCAN_API_KEY || ""
  }
}
