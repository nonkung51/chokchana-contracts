// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

library RandomGenerate {
    function randomGen(uint256 max) internal view returns (uint256 randomNumber) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % max;
    }
}