// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract PaymentEscrow {
    using SafeERC20 for IERC20;

    uint256 _orderId;

    mapping(address seller => mapping(uint256 orderId => uint256 amount)) private _payment;
    mapping(uint256 orderId => uint256 lock) private _paymentLock;
    mapping(uint256 orderId => IERC20 token) private _paymentType;

    function deposit(address token, uint256 amount, address seller) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), amount));
        unchecked {
            _orderId++;
        }
        uint256 orderId = _orderId;
        _paymentType[orderId] = IERC20(token);
        _paymentLock[orderId] = block.timestamp + 3 days;
        _payment[seller][orderId] = amount;
    }

    function withdraw(uint256 orderId) external {
        require(_paymentLock[orderId] < block.timestamp, "Time lock is valid.");

        IERC20 token = _paymentType[orderId];
        _paymentType[orderId] = IERC20(address(0));

        uint256 amount = _payment[msg.sender][orderId];
        _payment[msg.sender][orderId] = 0;

        token.safeTransfer(msg.sender, amount);
    }
}
