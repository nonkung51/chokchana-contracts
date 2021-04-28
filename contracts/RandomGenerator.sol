// This example code is designed to quickly deploy an example contract using Remix.

pragma solidity ^0.8.3;

import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";

import "./IChokchanaTicket.sol";

interface IChokchanaLottery {
    function setRewardNumber(uint8 rank, uint256 number) external;
    function summarizedRewards() external;
}


contract RandomGenerator is VRFConsumerBase {
    uint8 noOfRank;
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    IChokchanaLottery chokchanaLottery;
    IChokchanaTicket chokchanaTicket;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor(address _chokchanaLottery, address _chokchanaTicket, uint8 _noOfRank) 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        chokchanaTicket = IChokchanaTicket(_chokchanaTicket);
        chokchanaLottery = IChokchanaLottery(_chokchanaLottery);
        noOfRank = _noOfRank;
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }
    
    function drawRandomReward() public {
        getRandomNumber(block.difficulty);
    }
    
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        (uint256 start, uint256 end) = chokchanaTicket.range();
        for (uint8 i = 1; i <= noOfRank; i++) {
            uint256 _randomness = start + uint256(keccak256(abi.encode(randomness, i))) % (end - start);
            chokchanaLottery.setRewardNumber(i, _randomness);
        }
        chokchanaLottery.summarizedRewards();
    }
    
    /**
     * Withdraw LINK from this contract
     * 
     * DO NOT USE THIS IN PRODUCTION AS IT CAN BE CALLED BY ANY ADDRESS.
     * THIS IS PURELY FOR EXAMPLE PURPOSES.
     */
    function withdrawLink() external {
        require(LINK.transfer(msg.sender, LINK.balanceOf(address(this))), "Unable to transfer");
    }
}
