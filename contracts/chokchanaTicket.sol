// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

// ERC721 -> NFT
// ERC721Enumerable -> making NFT queriable
// Ownable for permission control of contract
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ChokchanaTicket is ERC721, ERC721Enumerable, Ownable {
    // curId keep track of last id of NFT generated
    uint256 curId;
    // current round of reward pools
    uint256 curRound;
    // round of each ticket (map with id)
    mapping(uint256 => uint256) public rounds;
    // mapping of round and id to ticket's number
    mapping(uint256 => mapping(uint256 => uint256)) public numbers;
    // numbers of tickets of each number in each round
    mapping(uint256 => mapping(uint256 => uint256)) public numOfNumbers;
    // whether the numbers in that round is exists
    mapping(uint256 => mapping(uint256 => bool)) public exists;
    // is that ticket id is claimed
    mapping(uint256 => bool) public claimed;
    // is the same number can be mint more than one time
    bool public multiple;
    
    // range of ticket numbers
    uint256 startNumber;
    uint256 endNumber;
    
    constructor(bool _multiple, uint256 _startNumber, uint256 _endNumber) ERC721("Chokchana Ticket", "CCNT") Ownable() {
        // Initialize everything
        curId = 0;
        multiple = _multiple;
        curRound = 1;
        
        startNumber = _startNumber;
        endNumber = _endNumber;
    }
    
    // return range of tickets number
    function range() public view returns(uint256, uint256) {
        return (startNumber, endNumber);
    }
    
    // reset all data for next round
    function nextRound() public /*onlyOwner*/ {
        curRound += 1;
    }

    // set ticket claim status to claimed
    function setClaim(uint256 id) public /*onlyOwner*/ {
        claimed[id] = true;
    }
    
    // Minting new tickets
    function mint(uint256 number, address to) public /*onlyOwner*/ {
        // check if ticket can be minted or not
        if (!multiple && exists[curRound][number]) {
            revert("Can only mint 1 ticket of same number!");
        }

        // check the range of tickets
        if (number < startNumber || number > endNumber) {
            revert("Can only mint ticket in range of startNumber -> endNumber");
        }
        
        // set variable to keep track of ticket's info
        numbers[curRound][curId] = number;
        exists[curRound][number] = true;
        
        if (exists[curRound][number]) {
            numOfNumbers[curRound][number] = numOfNumbers[curRound][number] + 1;
        } else {
            numOfNumbers[curRound][number] = 1;
        }
        
        rounds[curId] = curRound;
        
        // Mint and send to msg.sender
        _safeMint(to, curId);
        // Increment id for next ticket
        curId += 1;
    }
    
    // get info of each ticket
    function get(uint256 id) public view returns(uint256, uint256, bool) {
        return (numbers[rounds[id]][id], rounds[id], claimed[id]);
    }
    
    // get number of ticket of that ticket numbers minted
    function getNumberOf(uint256 round, uint256 ticketNumber) public view returns (uint256) {
        return numOfNumbers[round][ticketNumber];
    }
    
    /* ERC721Enumerable require to override */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}