// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ChokchanaTicket is ERC721, ERC721Enumerable, Ownable {
    uint256 curId;
    uint256 curRound;
    mapping(uint256 => uint256) public rounds;
    mapping(uint256 => mapping(uint256 => uint256)) public numbers;
    mapping(uint256 => mapping(uint256 => uint256)) public numOfNumbers;
    mapping(uint256 => mapping(uint256 => bool)) public exists;
    mapping(uint256 => bool) public claimed;
    bool public multiple;
    
    uint256 startNumber;
    uint256 endNumber;
    
    constructor(bool _multiple, uint256 _startNumber, uint256 _endNumber) ERC721("Chokchana Ticket", "CCNT") Ownable() {
        curId = 0;
        multiple = _multiple;
        curRound = 1;
        
        startNumber = _startNumber;
        endNumber = _endNumber;
    }
    
    function range() public view returns(uint256, uint256) {
        return (startNumber, endNumber);
    }
    
    // reset all data for next round
    function nextRound() public /*onlyOwner*/ {
        curRound += 1;
    }

    function setClaim(uint256 id) public /*onlyOwner*/ {
        claimed[id] = true;
    }
    
    function mint(uint256 number, address to) public /*onlyOwner*/ {
        if (!multiple && exists[curRound][number]) {
            revert("Can only mint 1 ticket of same number!");
        }

        if (number < startNumber || number > endNumber) {
            revert("Can only mint ticket in range of startNumber -> endNumber");
        }
        
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
        curId += 1;
    }
    
    function get(uint256 id) public view returns(uint256, uint256, bool) {
        return (numbers[rounds[id]][id], rounds[id], claimed[id]);
    }
    
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