// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ChokchanaTicket is ERC721, ERC721Enumerable, Ownable {
    uint256 curId;
    uint256 n;
    mapping(uint256 => uint256) public rounds;
    mapping(uint256 => mapping(uint256 => uint256)) public numbers;
    mapping(uint256 => mapping(uint256 => uint256)) public numOfNumbers;
    mapping(uint256 => mapping(uint256 => uint)) public issuesDate;
    mapping(uint256 => mapping(uint256 => bool)) public exists;
    bool public multiple;
    
    constructor(bool _multiple) ERC721("Chokchana Ticket", "CCNT") Ownable() {
        curId = 0;
        multiple = _multiple;
        n = 1;
    }
    
    // reset all data for next round
    function nextN() public onlyOwner {
        n += 1;
    }
    
    function mint(uint256 number) public {
        if (!multiple && exists[n][number]) {
            revert("Can only mint 1 ticket of same number!");
        }
        numbers[n][curId] = number;
        issuesDate[n][curId] = block.timestamp;
        exists[n][number] = true;
        
        if (exists[n][number]) {
            numOfNumbers[n][number] = numOfNumbers[n][number] + 1;
        } else {
            numOfNumbers[n][number] = 1;
        }
        
        rounds[curId] = n;
        
        // Mint and send to msg.sender
        _safeMint(msg.sender, curId);
        curId += 1;
    }
    
    function get(uint256 id) public view returns(uint256, uint, uint256) {
        return (numbers[rounds[id]][id], issuesDate[rounds[id]][id], rounds[id]);
    }
    
    function getNumberOf(uint256 ticketNumber) public view returns (uint256) {
        return numOfNumbers[n][ticketNumber];
    }
    
    /* ERC721Enumerable require to override */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}