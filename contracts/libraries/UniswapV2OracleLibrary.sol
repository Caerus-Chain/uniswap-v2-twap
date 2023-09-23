pragma solidity >=0.5.0;

import "../interfaces/IUniswapV2Pair.sol";

import "@uniswap/lib/contracts/libraries/FixedPoint.sol";

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    function getPastBlockTimestamp(
        uint256 blockNumber
    ) public pure returns (uint32) {
        // initialBlock = 17677;
        // initialTimestamp = 1695492557;
        uint256 blockDifference = blockNumber - 17677;
        uint256 timestamp = 1695492557 + (blockDifference * 2);

        return uint32(timestamp);
    }

    function getHistoricalData(
        address contractAddr,
        uint256 slotNumber,
        uint256 blockNumber
    ) public view returns (uint256 output) {
        require(blockNumber < block.number);

        bytes memory args = abi.encodePacked(
            contractAddr,
            slotNumber,
            blockNumber
        );
        bytes32 result;
        (, bytes memory returnData) = address(0x13).staticcall(args);

        for (uint256 i = 0; i < returnData.length; i++) {
            result |= bytes32(returnData[i] & 0xFF) >> (i * 8);
        }

        output = uint256(result);
    }

    function getReservesWithBlockNumber(
        address pair,
        uint256 pastBlockNumber
    )
        public
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)
    {
        uint256 data = getHistoricalData(pair, 8, pastBlockNumber);

        reserve0 = uint112((data << (8 * 4)) >> (8 * (32 - 14)));
        reserve1 = uint112((data << (8 * (4 + 14))) >> (8 * (32 - 14)));
        blockTimestampLast = uint32(data >> (8 * (32 - 4)));
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    )
        internal
        view
        returns (
            uint price0Cumulative,
            uint price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        ) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative +=
                uint(FixedPoint.fraction(reserve1, reserve0)._x) *
                timeElapsed;
            // counterfactual
            price1Cumulative +=
                uint(FixedPoint.fraction(reserve0, reserve1)._x) *
                timeElapsed;
        }
    }

    function pastCumulativePrices(
        address pair,
        uint256 pastBlockNumber
    )
        internal
        view
        returns (
            uint price0Cumulative,
            uint price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = getPastBlockTimestamp(pastBlockNumber);
        price0Cumulative = getHistoricalData(address(pair), 9, pastBlockNumber);
        price1Cumulative = getHistoricalData(
            address(pair),
            10,
            pastBlockNumber
        );

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        ) = getReservesWithBlockNumber(pair, pastBlockNumber);
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative +=
                uint(FixedPoint.fraction(reserve1, reserve0)._x) *
                timeElapsed;
            // counterfactual
            price1Cumulative +=
                uint(FixedPoint.fraction(reserve0, reserve1)._x) *
                timeElapsed;
        }
    }
}
