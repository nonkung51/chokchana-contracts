// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./IChokchanaTicket.sol";

contract ChokchanaLottery is Ownable {
    using SafeMath for uint256;

    // Interface for ticket and THBToken
    IChokchanaTicket ticket;
    IERC20 buyingCurrency;

    // current round of reward pool
    uint256 curRound;
    // price of ticket
    uint256 ticketPrice;
    // amount of buyingCurrency when no people got the reward carry to next round
    uint256 carryOnReward;
    // Reward as of now
    uint256 curReward;
    // percentage of reward for each rank
    // conserve last index for last 2 digit
    mapping(uint8 => uint256) rewardsPercentage;
    // lucky number!
    mapping(uint256 => mapping(uint8 => uint256)) rewardNumbers;
    // claimable reward for each numbers
    mapping(uint256 => mapping(uint256 => uint256)) claimableReward;
    // this keep track for pool that have last 2 digits reward
    mapping(uint256 => mapping(uint256 => uint256)) endsWith;
    // how many rank of reward of this pool
    uint8 noOfRank;
    // is pool in buying period
    bool public buyingPeriod;

    // Initialize everything
    constructor(
        address _ticket,
        address _buyingCurrency,
        uint8 _noOfRank,
        uint256 _ticketPrice
    ) Ownable() {
        ticket = IChokchanaTicket(_ticket);
        buyingCurrency = IERC20(_buyingCurrency);
        curRound = 1;
        noOfRank = _noOfRank;
        ticketPrice = _ticketPrice;
    }

    // getter for buyingPeriod
    function getBuyingPeriod() public view returns(bool) {
        return buyingPeriod;
    }

    // setter for buyingPeriod
    function setBuyingPeriod(bool _buyingPeriod) public {
        buyingPeriod = _buyingPeriod;
    }

    // set reward for each rank
    function setReward(uint8 rank, uint256 percentage) public {
        // last rank will be use as percentage for last 2 digits reward
        require(
            rank <= noOfRank + 1,
            "require rank to be less than number of rank!"
        );
        require(rank >= 0, "require rank to be more than 0!!");
        require(
            percentage <= 100,
            "require percentage to be in range 1 - 100!!"
        );
        require(percentage > 0, "require percentage to be more than 0!!");

        rewardsPercentage[rank] = percentage;
    }

    function buyTicket(uint256 number) public {
        require(buyingPeriod == true, "You have to buy ticket in buying period!");
        // transfer buying currency to this contract
        buyingCurrency.transferFrom(msg.sender, address(this), ticketPrice);

        // keep track last 2nd digits
        // For last 2nd digits reward
        if (endsWith[curRound][number.mod(100)] == 0) {
            endsWith[curRound][number.mod(100)] = 1;
        } else {
            endsWith[curRound][number.mod(100)] += 1;
        }

        // add ticketPrice to curReward
        curReward = curReward.add(ticketPrice);
        // mint ticket NFT then transfer to msg.sender
        ticket.mint(number, msg.sender);
    }
    
    // Draw reward
    function summarizedRewards() public {
        distributeReward();

        // set up for next round
        curRound = curRound.add(1);
        ticket.nextRound();
        curReward = 0;
    }

    function distributeReward() private {
        // how much reward will be avalible to distribute?
        // we keep some of it to the pool as fee
        uint256 allocatableReward =
            curReward.mul(95).div(100).add(carryOnReward);

        // distribute reward for generic reward
        for (uint8 i = 0; i < noOfRank; i++) {
            // Holy fuck!! please don't bug!!
            // If picked reward is not bought then added it to carryOnReward for next round

            // get how many ticket with ticket number (ticket number that avalible to claim reward)
            uint256 numOfTicket =
                ticket.getNumberOf(curRound, rewardNumbers[curRound][i]);

            
            if (numOfTicket != 0) {
                // if there ticket with that number bought update value of claimableReward
                claimableReward[curRound][
                    rewardNumbers[curRound][i]
                ] = allocatableReward.mul(rewardsPercentage[i]).div(100).div(
                    numOfTicket
                );
            } else {
                // if no ticket with that number bought!
                carryOnReward += allocatableReward
                    .mul(rewardsPercentage[i])
                    .div(100);
            }
        }

        // distribute for 2nd digits
        // first checking if this pool set up for last 2nd digits reward
        if (rewardsPercentage[noOfRank] != 0) {
            // This is intriguing...

            // check if pool has first rank reward so we can assign claimableReward correctly
            if (claimableReward[curRound][rewardNumbers[curRound][0]] > 0) {
                uint256 last2ndDigits = rewardNumbers[curRound][0].mod(100);
                claimableReward[curRound][last2ndDigits] = allocatableReward
                    .mul(rewardsPercentage[noOfRank])
                    .div(100)
                    .div(endsWith[curRound][last2ndDigits] - 1);
            } else {
                uint256 last2ndDigits = rewardNumbers[curRound][0].mod(100);
                claimableReward[curRound][last2ndDigits] = allocatableReward
                    .mul(rewardsPercentage[noOfRank])
                    .div(100)
                    .div(endsWith[curRound][last2ndDigits]);
            }
        }
    }

    // claimReward with ticketId
    function claimReward(uint256 ticketId) public {
        require(
            ticket.ownerOf(ticketId) == msg.sender,
            "Require owner of token!!"
        );
        // get ticket info
        (uint256 number, uint256 round, bool claimed) = ticket.get(ticketId);
        require(
            (claimableReward[round][number] > 0) ||
                (claimableReward[round][number.mod(100)] > 0),
            "You are not eligible for reward claim!"
        );
        require(!claimed, "You already claim reward!");

        // if ticket got whole number reward
        // else if for ticket got last 2nd digits reward
        if (claimableReward[round][number] > 0) {
            uint256 numOfTicket = ticket.getNumberOf(round, number);
            buyingCurrency.transfer(
                msg.sender,
                claimableReward[round][number].div(numOfTicket)
            );
            claimableReward[round][number] = claimableReward[round][number].sub(
                claimableReward[round][number].div(numOfTicket)
            );
        } else if (claimableReward[round][number.mod(100)] > 0) {
            uint256 numOfTicket = endsWith[round][number.mod(100)];
            buyingCurrency.transfer(
                msg.sender,
                claimableReward[round][number.mod(100)].div(numOfTicket)
            );
            claimableReward[round][number.mod(100)] = claimableReward[round][
                number.mod(100)
            ]
                .sub(claimableReward[round][number.mod(100)].div(numOfTicket));
        }

        // set ticket is claimed
        ticket.setClaim(ticketId);
    }

    // get number that got reward
    // TODO: maybe changing the name?
    function getReward(uint8 round, uint8 rank) public view returns (uint256) {
        return rewardNumbers[round][rank];
    }

    function getClaimInfo(uint8 round, uint8 number)
        public
        view
        returns (uint256)
    {
        return claimableReward[round][number];
    }

    function getTotalReward() public view returns (uint256) {
        return carryOnReward.add(curReward);
    }
}
