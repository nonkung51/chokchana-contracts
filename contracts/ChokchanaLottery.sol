// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

import "./libraries/RandomGenerate.sol";
import "./IChokchanaTicket.sol";

contract ChokchanaLottery is Ownable {
    using SafeMath for uint256;

    IChokchanaTicket ticket;
    IERC20 buyingCurrency;

    uint256 curRound;
    uint256 ticketPrice;
    uint256 carryOnReward;
    uint256 curReward;
    mapping(uint8 => uint256) rewardsPercentage;
    mapping(uint256 => mapping(uint256 => bool)) mintedTickets;
    mapping(uint256 => mapping(uint8 => uint256)) rewardNumbers;
    mapping(uint256 => mapping(uint256 => uint256)) claimableReward;
    uint8 noOfRank;
    
    constructor(address _ticket, address _buyingCurrency, uint8 _noOfRank, uint256 _ticketPrice) Ownable() {
        ticket = IChokchanaTicket(_ticket);
        buyingCurrency = IERC20(_buyingCurrency);
        curRound = 1;
        noOfRank = _noOfRank;
        ticketPrice = _ticketPrice;
    }

    function setReward(uint8 rank, uint256 percentage) public onlyOwner {
        require(rank < noOfRank, "require rank to be less than number of rank!");
        require(rank >= 0, "require rank to be more than 0!!");
        require(percentage <= 100, "require percentage to be in range 1 - 100!!");
        require(percentage > 0, "require percentage to be more than 0!!");

        // TODO: This might be not so safe!

        rewardsPercentage[rank] = percentage;
    }

    function buyTicket(uint256 number) public {
        buyingCurrency.transferFrom(msg.sender, address(this), ticketPrice);
        curReward = curReward.add(ticketPrice);
        ticket.mint(number, msg.sender);
        mintedTickets[curRound][number] = true;
    }
    
    function drawRewards() public onlyOwner {
        for (uint8 i = 0; i < noOfRank; i++) {
            (uint256 startNumber, uint256 endNumber) = ticket.range();
            rewardNumbers[curRound][i] = runRandom(startNumber, endNumber, i);
        }
        distributeReward();
        curRound.add(1);
        curReward = 0;
    }

    function distributeReward() private {
        uint256 allocatableReward = curReward.mul(95).div(100).add(carryOnReward);

        console.log('curReward', curReward);
        console.log('allocatableReward', allocatableReward);

        for (uint8 i = 0; i < noOfRank; i++) {
            // Holy fuck!! please don't bug!!
            // If picked reward is not bought then added it to carryOnReward for next round
            if(mintedTickets[curRound][rewardNumbers[curRound][i]]) {
                claimableReward[curRound][rewardNumbers[curRound][i]] = allocatableReward.mul(rewardsPercentage[i]).div(100);
                console.log(claimableReward[curRound][rewardNumbers[curRound][i]], rewardNumbers[curRound][i]);
            } else {
                carryOnReward += allocatableReward.mul(rewardsPercentage[i]).div(100);
            }
        }   
    }
    
    function runRandom(uint256 from, uint256 to, uint256 seed) private view returns (uint256) {
        return from + RandomGenerate.randomGen(to, seed);
    }
    
    function getReward(uint8 round, uint8 rank) public view returns (uint256) {
        return rewardNumbers[round][rank];
    }

    function getClaimInfo(uint8 round, uint8 number) public view returns (uint256) {
        return claimableReward[round][number];
    }

    function getTotalReward() public view returns (uint256) {
        return carryOnReward.add(curReward);
    }
}