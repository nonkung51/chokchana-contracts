// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ChokchanaTicket is ERC721, ERC721Enumerable, Ownable {
    uint256 curId;
    mapping(uint256 => uint256) public numbers;
    mapping(uint256 => uint256) public numOfNumbers;
    mapping(uint256 => uint) public issuesDate;
    mapping(uint256 => bool) public exists;
    bool public multiple;
    
    constructor(bool _multiple) ERC721("Chokchana Ticket", "CCNT") Ownable() {
        curId = 0;
        multiple = _multiple;
    }
    
    function mint(uint256 number) public {
        if (!multiple && exists[number]) {
            revert("Can only mint 1 ticket of same number!");
        }
        numbers[curId] = number;
        issuesDate[curId] = block.timestamp;
        exists[number] = true;
        
        if (exists[number]) {
            numOfNumbers[number] = numOfNumbers[number] + 1;
        } else {
            numOfNumbers[number] = 1;
        }
        
        // Mint and send to msg.sender
        _safeMint(msg.sender, curId);
        curId += 1;
    }
    
    function get(uint256 idx) public view returns(uint256, uint) {
        return (numbers[idx], issuesDate[idx]);
    }
    
    function getNumberOf(uint256 ticketNumber) public view returns (uint256) {
        return numOfNumbers[ticketNumber];
    }
    
    /* ERC721Enumerable require to override */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}