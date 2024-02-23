require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3");
require("dotenv").config();



module.exports = {
  
  networks: {
    polygon: {
      // url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_PVT_KEY}`,
      url: `${process.env.RPC}`,
      accounts: [`0x${process.env.PVTKEY}`],
    },
    ethereum: {
      // url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_PVT_KEY}`,
      url: `${process.env.ETHRPC}`,
      accounts: [`0x${process.env.PVTKEY}`],
    },
    bsc: {
      // url: `https://polygon-mumbai.g.alchemy.com/v2/${process.env.ALCHEMY_PVT_KEY}`,
      url: `${process.env.BSC_RPC}`,
      accounts: [`0x${process.env.PVTKEY}`],
    },
  },
  etherscan: {
    apiKey: process.env.API_KEY_BSC,
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
};
