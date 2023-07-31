// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract CensorERC20 is ERC20("Censor", "CSR") {
    address private _centralAuthority;

    constructor(address centralAuthority) {
        _centralAuthority = centralAuthority;
    }

    modifier onlyAdmin() {
        require(msg.sender == _centralAuthority, "Not authorized");
        _;
    }

    function mint(address account, uint256 amount) external onlyAdmin {
        _mint(account, amount);
    }

    function transferFromCensor(address from, address to, uint256 amount) external virtual returns (bool) {
        require(msg.sender == _centralAuthority, "Not authorized");
        _transfer(from, to, amount);
        return true;
    }
}
