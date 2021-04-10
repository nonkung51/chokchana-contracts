// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;
import "hardhat/console.sol";

library RandomGenerate {
    function randomGen(uint256 max, uint256 seed) internal view returns (uint256 randomNumber) {
        uint256 rand = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, seed))) % max;
        console.log('rand num: ', rand);
        return rand;
    }
}