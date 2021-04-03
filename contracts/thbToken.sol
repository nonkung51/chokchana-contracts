// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract THBToken is ERC20 {
    address public minter;

    constructor() ERC20("Thai Baht", "THB") {
        minter = msg.sender;
    }

    function mint(uint256 amount) public {
        require(msg.sender == minter, "Minting new token require minter");
        _mint(minter, amount);
    }
}
