// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/IERC20.sol";

contract UntrustedEscrow {
    mapping(address buyer => mapping(address seller => address token)) public paymentType;
    mapping(address seller => mapping(address buyer => uint256 amount)) public accountBal;
    mapping(address seller => mapping(address buyer => uint256 lock)) public accountLock;

    function deposit(address token, uint256 amount, address seller) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), amount));
        paymentType[msg.sender][seller] = token;
        accountBal[seller][msg.sender] = amount;
        accountLock[seller][msg.sender] = block.timestamp + 3 days;
    }

    function withdraw(address buyer) external {
        require(accountLock[msg.sender][buyer] <= block.timestamp);
        address token = paymentType[buyer][msg.sender];
        uint256 amount = accountBal[msg.sender][buyer];
        require(IERC20(token).transfer(msg.sender, amount));
    }

    // TODO: check for vulnerabilities
}
