// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract SanctionERC20 is ERC20("Sanction", "STN") {
    mapping(address => bool) _blacklist;

    address private immutable _admin1;
    address private immutable _admin2;

    event Blacklisted(address indexed _target);
    event Released(address indexed _target);

    constructor(address[2] memory admin) {
        _admin1 = admin[0];
        _admin2 = admin[1];
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin1 || msg.sender == _admin2, "Not authorized");
        _;
    }

    function mint(address account, uint256 amount) external onlyAdmin {
        _mint(account, amount);
    }

    function blacklistAdd(address target) external onlyAdmin {
        _blacklist[target] = true;
        emit Blacklisted(target);
    }

    function blacklistRemove(address target) external onlyAdmin {
        _blacklist[target] = false;
        emit Released(target);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view override {
        require(_blacklist[to] != true, "Receiver blacklisted");
        require(_blacklist[from] != true, "Sender blacklisted");
    }
}
