// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "../libraries/RandomGenerate.sol";

contract Random {
    uint256 public randomNum;

    function runRandom(uint256 from, uint256 to, uint256 seed) public {
        randomNum = from + RandomGenerate.randomGen(to - from, seed);
    }

    function getRandomNum() public view returns (uint256) {
        return randomNum;
    }
}
