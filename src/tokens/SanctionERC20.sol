// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SanctionERC20 is ERC20("Sanction", "STN") {
    mapping(address => bool) _blacklist;

    mapping(address => bool) _admin;

    constructor(address[2] memory admin) {
        _admin[admin[0]] = true;
        _admin[admin[1]] = true;
    }

    modifier onlyAdmin() {
        require(_admin[msg.sender] == true, "Not authorized!");
        _;
    }

    function mint(address account, uint256 amount) external onlyAdmin {
        _mint(account, amount);
    }

    function blacklistAdd(address target) external onlyAdmin {
        _blacklist[target] = true;
    }

    function blacklistRemove(address target) external onlyAdmin {
        _blacklist[target] = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view override {
        require(_blacklist[to] != true, "Receiver blacklisted!");
        require(_blacklist[from] != true, "Sender blacklisted!");
    }
}
