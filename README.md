# UniswapV2TWAPOracle Contract
The `UniswapV2TWAPOracle` is a Solidity smart contract that calculates the Time-Weighted Average Price (TWAP) for a Uniswap V2 pair. The contract utilizes both current and past cumulative prices to generate an average price that is resistant to manipulation.

### Methods
1. **consult(address token, uint amountIn, uint256 pastBlockNumber)**
- Calculates the Time-Weighted Average Price (TWAP) for a given `token` in a Uniswap V2 pair.

## Prerequisites
- **Node.js** v12+ LTS and npm (comes with Node)
- **Hardhat**

## Installation
Clone the repository:
```
git clone https://github.com/Caerus-Chain/uniswap-v2-twap
```
Navigate to the project folder:
```
cd uniswap-v2-twap
```
Install dependencies:
```
npm install
```

## Set Up Configuration:
1. Review the `.example.env` file.
2. Create a `.env` file based on the example and adjust the values as needed.

For Linux or macOS:
```
cp .example.env .env
```
For Windows:
```
copy .example.env .env
```

## Compilation
Compile the smart contracts using Hardhat:
```
npx hardhat compile
```

## Quick Start Guide
### 1. Deployment:
Run the following command to compile the contracts using the Solidity compiler and deploy the `UniswapV2TWAPOracle` to your Caerus network.
```
npx hardhat run scripts/deploy.js --network caerus
```

## Conclusion
If you would like to contribute to the project, please fork the repository, make your changes, and then submit a pull request. We appreciate all contributions and feedback!
