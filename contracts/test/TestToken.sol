// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("TestToken", "TT") {
        _mint(msg.sender, initialSupply);
    }
}
