pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
    // is pool in buying period
    bool public buyingPeriod;

    //******Time
    uint public startThisRound;
    uint public nextDraw;
    uint public lockBeforeDraw;
    uint public canBuyTime;

    // Initialize everything
    constructor(
        address _ticket,
        address _buyingCurrency,
        uint256 _ticketPrice,

        uint _nextDraw,//******Time
        uint _lockBeforeDraw
    ) Ownable() {
        ticket = IChokchanaTicket(_ticket);
        buyingCurrency = IERC20(_buyingCurrency);
        curRound = 1;
        ticketPrice = _ticketPrice;

        startThisRound = block.timestamp; //******Time
        nextDraw = _nextDraw;
        lockBeforeDraw = _lockBeforeDraw;
        canBuyTime = startThisRound + nextDraw - lockBeforeDraw;
        buyingPeriod = true;
    }

    function setNextDraw(uint _nextDraw) public {
        startThisRound = block.timestamp;
        nextDraw = _nextDraw;
        canBuyTime = startThisRound + nextDraw - lockBeforeDraw;
    }
    
    function setlockBeforeDraw(uint _lockBeforeDraw) public {
        startThisRound = block.timestamp;
        lockBeforeDraw = _lockBeforeDraw;
        canBuyTime = startThisRound + nextDraw - lockBeforeDraw;
    }

    // getter for buyingPeriod
    function getBuyingPeriod() public view returns(bool) {
        return buyingPeriod;
    }

    // setter for buyingPeriod
    function setBuyingPeriod(bool _buyingPeriod) public {
        buyingPeriod = _buyingPeriod;
    }

    // setter for lucky number!!
    function setRewardNumber(uint8 _rank, uint256 _rewardNumber) public onlyOwner() {
        rewardNumbers[curRound][_rank] = _rewardNumber;
    }

    // set reward for each number
    function setClaimableReward(uint8 rank, uint256 reward) public onlyOwner() {
        claimableReward[rank] = reward;
    }

    // go to next round of lottery
    function nextRound() public onlyOwner() {
        ticket.nextRound();
        curRound = curRound.add(1);
    }

    // claim reward
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
        //******Time
        console.log("Buying At: ");
        console.log(block.timestamp, canBuyTime);
        if(block.timestamp < canBuyTime){
            buyingPeriod = true;
        }
        else{
            buyingPeriod = false;
        }
        
        require(buyingPeriod == true, "You have to buy ticket in buying period!");
        // transfer buying currency to this contract
        buyingCurrency.transferFrom(msg.sender, address(this), ticketPrice);
        // add ticketPrice to curReward
        curDeposit = curDeposit.add(ticketPrice);
        // mint ticket NFT then transfer to msg.sender
        ticket.mint(number, msg.sender);
    }
}
