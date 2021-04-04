pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./libraries/RandomGenerate.sol";
import "./IChokchanaTicket.sol";

contract ChokchanaLottery is Ownable {
    IChokchanaTicket ticket;
    uint256 curRound;
    // Mapping round no. => rank => rewardNumber
    mapping(uint256 => mapping(uint8 => uint256)) rewardNumbers;
    uint8 noOfRank;
    
    constructor(address _ticket, uint8 _noOfRank) {
        ticket = IChokchanaTicket(_ticket);
        curRound = 1;
        noOfRank = _noOfRank;
    }
    
    function drawRewards() public onlyOwner {
        for (uint8 i = 0; i < noOfRank; i++) {
            rewardNumbers[curRound][i] = runRandom(1111, 9999, i);
        }
        curRound += 1;
    }
    
    function runRandom(uint256 from, uint256 to, uint256 seed) private returns (uint256) {
        return from + RandomGenerate.randomGen(to, seed);
    }
    
    function getReward(uint8 round, uint8 rank) public view returns (uint256) {
        return rewardNumbers[round][rank];
    }
}