// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "hardhat/console.sol";
import "./libraries/RandomGenerate.sol";

contract Random {
    uint256 public randomNum;

    function runRandom(uint256 from, uint256 to) public {
        randomNum = from + RandomGenerate.randomGen(to - from);
    }

    function getRandomNum() public view returns (uint256) {
        return randomNum;
    }
}
