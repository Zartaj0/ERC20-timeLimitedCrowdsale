require("@nomicfoundation/hardhat-toolbox");
require ("dotenv").config();
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      // This value will be replaced on runtime
      url: process.env.STAGING_QUICKNODE_KEY,
      accounts: [process.env.PRIVATE_KEY],
      timeout:60000
    },
    ropsten: {
      // This value will be replaced on runtime
      url: process.env.ROPSTEN_INFURA_API,
      accounts: [process.env.PRIVATE_KEY],
      timeout:60000
    },
    mumbai: {
      // This value will be replaced on runtime
      url: process.env.ALCHEMY_KEY_POLYGON,
      accounts: [process.env.PRIVATE_KEY],
      timeout:60000
    }
  },
  gasReporter:{
    enabled:true
  },
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGON_API
    }
  }
};
