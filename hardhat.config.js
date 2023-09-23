require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [{
      version: "0.6.6",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        }
      },
    }],
  },
  networks: {
    hardhat: {
      forking: {
        url: "http://18.216.66.253:38545",
      }
    },
    caerus: {
      url: "http://18.216.66.253:38545",
    },
  }
};