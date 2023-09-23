// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.6;

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function getReserves() external view returns (uint112, uint112, uint32);
}
