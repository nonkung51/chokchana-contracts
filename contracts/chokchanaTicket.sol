// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract ChokchanaTicket is ERC721, ERC721Enumerable {
    uint256[] public numbers;
    
    constructor() ERC721("Chokchana Ticket", "CCNT") {
        
    }
    
    function mint(uint256 number) public {
        numbers.push(number);
        _safeMint(msg.sender, numbers.length - 1);
    }
    
    /* ERC721Enumerable require to override */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}