const hre = require("hardhat");

const pairAddress = require("../config/contractAddrs.json")["WETH-Caerus-V2"];

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const UniswapV2TWAPOracle = await hre.ethers.getContractFactory("UniswapV2TWAPOracle");
  const uniswapV2TWAPOracle = await UniswapV2TWAPOracle.deploy(pairAddress);

  await uniswapV2TWAPOracle.deployed();

  console.log("UniswapV2TWAPOracle deployed to:", uniswapV2TWAPOracle.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
// Deploying contracts with the account: 0xa40aa030A3ba4f42FDCd2B7bC33d5B03770290ea
// UniswapV2TWAPOracle deployed to: 0xCfC0306a3834857E764aFDa39bbeAF71952EfDfC