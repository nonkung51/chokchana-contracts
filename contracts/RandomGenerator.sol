// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";

interface IChokchanaLottery {
    function setRewardNumber(uint8 rank, uint256 number) external;
    function summarizedRewards() external;
}

contract RandomGenerator is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    IChokchanaLottery chokchanaLottery;
    
    uint256 curRound;
    uint8 noOfRank;
    uint8 private alreadyGenerate;
    mapping(uint256 => mapping(uint8 => uint256)) numbers;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor(address _chokchanaLottery, uint8 _noOfRank) 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        chokchanaLottery = IChokchanaLottery(_chokchanaLottery);
        noOfRank = _noOfRank;
        curRound = 1;
        alreadyGenerate = 0;
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (varies by network)
    }
    
    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        numbers[curRound][alreadyGenerate] = randomness;
        chokchanaLottery.setRewardNumber(alreadyGenerate, randomness);
        if (alreadyGenerate < noOfRank) {
            alreadyGenerate += 1;
            getRandomNumber(block.difficulty);
        } else {
            chokchanaLottery.summarizedRewards();
            alreadyGenerate = 0;
            curRound += 1;
        }
    }
    
    function getGenerateNumber(uint256 round, uint8 rank) public view returns (uint256) {
        return numbers[round][rank];
    }
}