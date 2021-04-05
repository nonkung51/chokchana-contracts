pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./libraries/RandomGenerate.sol";
import "./IChokchanaTicket.sol";

contract ChokchanaLottery is Ownable {
    IChokchanaTicket ticket;
    IERC20 buyingCurrency;

    uint256 curRound;
    uint256 ticketPrice;
    mapping(uint256 => mapping(uint8 => uint256)) rewardNumbers;
    uint8 noOfRank;
    
    constructor(address _ticket, address _buyingCurrency, uint8 _noOfRank, uint256 _ticketPrice) Ownable() {
        ticket = IChokchanaTicket(_ticket);
        buyingCurrency = IERC20(_buyingCurrency);
        curRound = 1;
        noOfRank = _noOfRank;
        ticketPrice = _ticketPrice;
    }

    function buyTicket(uint256 number) public {
        buyingCurrency.transferFrom(msg.sender, address(this), ticketPrice);
        ticket.mint(number, msg.sender);
    }
    
    function drawRewards() public onlyOwner {
        for (uint8 i = 0; i < noOfRank; i++) {
            (uint256 startNumber, uint256 endNumber) = ticket.range();
            rewardNumbers[curRound][i] = runRandom(startNumber, endNumber, i);
        }
        curRound += 1;
    }
    
    function runRandom(uint256 from, uint256 to, uint256 seed) private view returns (uint256) {
        return from + RandomGenerate.randomGen(to, seed);
    }
    
    function getReward(uint8 round, uint8 rank) public view returns (uint256) {
        return rewardNumbers[round][rank];
    }
}