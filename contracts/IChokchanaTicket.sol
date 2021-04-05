// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

interface IChokchanaTicket {
    // Chokchana
    function nextRound() external;
    function mint(uint256 number, address to) external;
    function get(uint256 id) external view returns(uint256, uint, uint256);
    function getNumberOf(uint256 ticketNumber) external view returns (uint256);
    function range() external view returns(uint256, uint256);

    // ERC721Enumerable
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}