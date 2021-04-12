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
    // conserve last 2 indices for last 2 digits & 3 digits
    mapping(uint8 => uint256) rewardsPercentage;
    mapping(uint256 => mapping(uint8 => uint256)) rewardNumbers;
    mapping(uint256 => mapping(uint256 => uint256)) claimableReward;
    mapping(uint256 => mapping(uint256 => uint256)) endsWith;
    uint8 noOfRank;
    
    constructor(address _ticket, address _buyingCurrency, uint8 _noOfRank, uint256 _ticketPrice) Ownable() {
        ticket = IChokchanaTicket(_ticket);
        buyingCurrency = IERC20(_buyingCurrency);
        curRound = 1;
        noOfRank = _noOfRank;
        ticketPrice = _ticketPrice;
    }

    function setReward(uint8 rank, uint256 percentage) public onlyOwner {
        // last 2 rank will be use as percentage for last 2 digits, 3 digits reward
        require(rank < noOfRank + 2, "require rank to be less than number of rank!");
        require(rank >= 0, "require rank to be more than 0!!");
        require(percentage <= 100, "require percentage to be in range 1 - 100!!");
        require(percentage > 0, "require percentage to be more than 0!!");

        // TODO: This might be not so safe!

        rewardsPercentage[rank] = percentage;
    }

    function buyTicket(uint256 number) public {
        buyingCurrency.transferFrom(msg.sender, address(this), ticketPrice);

        // For 2nd digits reward
        if (endsWith[curRound][number.mod(100)] == 0) {
            endsWith[curRound][number.mod(100)] = 1;
        } else {
            endsWith[curRound][number.mod(100)] += 1;
        }

        // For 3rd digits reward
        if (endsWith[curRound][number.mod(1000)] == 0) {
            endsWith[curRound][number.mod(1000)] = 1;
        } else {
            endsWith[curRound][number.mod(1000)] += 1;
        }

        curReward = curReward.add(ticketPrice);
        ticket.mint(number, msg.sender);
    }
    
    function drawRewards() public onlyOwner {
        for (uint8 i = 0; i < noOfRank; i++) {
            (uint256 startNumber, uint256 endNumber) = ticket.range();
            console.log('random in range: ', startNumber, endNumber);
            console.log('got number: ', runRandom(startNumber, endNumber, i));
            console.log('curRound: ', curRound);
            rewardNumbers[curRound][i] = runRandom(startNumber, endNumber, i);
        }
        distributeReward();
        curRound = curRound.add(1);
        ticket.nextRound();
        curReward = 0;
    }

    function distributeReward() private {
        uint256 allocatableReward = curReward.mul(95).div(100).add(carryOnReward);

        console.log('curReward', curReward);
        console.log('allocatableReward', allocatableReward);

        // distribute reward for generic reward
        for (uint8 i = 0; i < noOfRank; i++) {
            // Holy fuck!! please don't bug!!
            // If picked reward is not bought then added it to carryOnReward for next round
            uint256 numOfTicket = ticket.getNumberOf(curRound, rewardNumbers[curRound][i]);
            if(numOfTicket != 0) {
                claimableReward[curRound][rewardNumbers[curRound][i]] = allocatableReward.mul(rewardsPercentage[i]).div(100).div(numOfTicket);
                console.log(claimableReward[curRound][rewardNumbers[curRound][i]], rewardNumbers[curRound][i]);
            } else {
                carryOnReward += allocatableReward.mul(rewardsPercentage[i]).div(100);
            }
        }

        // distribute for 3rd digits
    }

    function claimReward(uint256 ticketId) public {
        require(ticket.ownerOf(ticketId) == msg.sender, "Require owner of token!!");
        (uint256 number, uint256 round, bool claimed) = ticket.get(ticketId);
        require(claimableReward[round][number] > 0, "You are not eligible for reward claim!");
        require(!claimed, "You already claim reward!");

        uint256 numOfTicket = ticket.getNumberOf(round, number);
        buyingCurrency.transfer(msg.sender, claimableReward[round][number].div(numOfTicket));
        claimableReward[round][number] = claimableReward[round][number].sub(claimableReward[round][number].div(numOfTicket));
        ticket.setClaim(ticketId);
    }
    
    function runRandom(uint256 from, uint256 to, uint256 seed) private view returns (uint256) {
        return from + RandomGenerate.randomGen(to - from, seed);
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