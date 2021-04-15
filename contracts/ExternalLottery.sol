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

    function setRewardNumber(uint8 _rank, uint256 _rewardNumber) public onlyOwner() {
        rewardNumbers[curRound][_rank] = _rewardNumber;
    }

    function setClaimableReward(uint8 rank, uint256 reward) public onlyOwner() {
        claimableReward[rank] = reward;
    }

    function nextRound() public onlyOwner() {
        curRound = curRound.add(1);
    }

    function claimReward(uint256 ticketId, uint8 rank) public {
        (uint256 number, uint256 round, bool claimed) = ticket.get(ticketId);
        require(
            number == rewardNumbers[round][rank],
            "You are not eligible to claim this reward!"
        );
        require(!claimed, "You already claim reward!");
        buyingCurrency.transfer(msg.sender, claimableReward[rank]);
    }

    function buyTicket(uint256 number) public {
        // transfer buying currency to this contract
        buyingCurrency.transferFrom(msg.sender, address(this), ticketPrice);
        // add ticketPrice to curReward
        curDeposit = curDeposit.add(ticketPrice);
        // mint ticket NFT then transfer to msg.sender
        ticket.mint(number, msg.sender);
    }
}
