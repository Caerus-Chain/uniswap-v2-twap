// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import "./interfaces/IUniswapV2Pair.sol";
import "./libraries/UniswapV2OracleLibrary.sol";

import "@uniswap/lib/contracts/libraries/FixedPoint.sol";

contract UniswapV2TWAPOracle {
    using FixedPoint for *;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    constructor(address pairAddress) public {
        IUniswapV2Pair _pair = IUniswapV2Pair(pairAddress);
        pair = _pair;
        token0 = _pair.token0();
        token1 = _pair.token1();
    }

    function calculateTwap(
        uint256 pastBlockNumber
    )
        public
        view
        returns (
            FixedPoint.uq112x112 memory price0Average,
            FixedPoint.uq112x112 memory price1Average
        )
    {
        (
            uint256 currentPrice0Cumulative,
            uint256 currentPrice1Cumulative,
            uint32 currentBlockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));

        (
            uint256 pastPrice0Cumulative,
            uint256 pastPrice1Cumulative,
            uint32 pastTimestamp
        ) = UniswapV2OracleLibrary.pastCumulativePrices(
                address(pair),
                pastBlockNumber
            );

        uint32 timeElapsed = currentBlockTimestamp - pastTimestamp;

        price0Average = FixedPoint.uq112x112(
            uint224(
                (currentPrice0Cumulative - pastPrice0Cumulative) / timeElapsed
            )
        );
        price1Average = FixedPoint.uq112x112(
            uint224(
                (currentPrice1Cumulative - pastPrice1Cumulative) / timeElapsed
            )
        );
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(
        address token,
        uint amountIn,
        uint256 pastBlockNumber
    ) external view returns (uint amountOut) {
        (
            FixedPoint.uq112x112 memory price0Average,
            FixedPoint.uq112x112 memory price1Average
        ) = calculateTwap(pastBlockNumber);
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        } else {
            require(token == token1, "UniswapV2TWAPOracle::consult: INVALID_TOKEN");
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }
}
