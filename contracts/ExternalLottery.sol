pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

import "./libraries/RandomGenerate.sol";
import "./IChokchanaTicket.sol";

contract ExternalLottery is Ownable {
    using SafeMath for uint256;

    // Interface for ticket and THBToken
    IChokchanaTicket ticket;
    IERC20 buyingCurrency;

    // current round of reward pool
    uint256 curRound;
    // price of ticket
    uint256 ticketPrice;
    // deposit as of now
    uint256 curDeposit;
    // lucky number!
    mapping(uint256 => mapping(uint8 => uint256)) rewardNumbers;
    // claimable reward for each rank
    mapping(uint8 => uint256) claimableReward;

    // Initialize everything
    constructor(
        address _ticket,
        address _buyingCurrency,
        uint256 _ticketPrice
    ) Ownable() {
        ticket = IChokchanaTicket(_ticket);
        buyingCurrency = IERC20(_buyingCurrency);
        curRound = 1;
        ticketPrice = _ticketPrice;
    }
}