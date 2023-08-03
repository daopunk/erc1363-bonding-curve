// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "test/TestHelper.sol";

contract BondingCurve is TestHelper {
    function testBuy() public {
        emit log_named_uint("scale     ", reserveToken.scale() / 1e9);
        emit log_named_uint("reserveBal", reserveToken.reserveBalance() / 1e9);

        vm.startPrank(alice);
        reserveToken.buy{value: 100 ether}();
        emit log_named_uint("alice     ", reserveToken.balanceOf(alice) / 1e9);
        emit log_named_uint("scale     ", reserveToken.scale() / 1e9);
        emit log_named_uint("reserveBal", reserveToken.reserveBalance() / 1e9);
        vm.stopPrank();

        vm.startPrank(bob);
        reserveToken.buy{value: 250 ether}();
        emit log_named_uint("alice     ", reserveToken.balanceOf(alice) / 1e9);
        emit log_named_uint("bob       ", reserveToken.balanceOf(bob) / 1e9);
        emit log_named_uint("scale     ", reserveToken.scale() / 1e9);
        emit log_named_uint("reserveBal", reserveToken.reserveBalance() / 1e9);
        vm.stopPrank();

        vm.startPrank(cobra);
        reserveToken.buy{value: 750 ether}();
        emit log_named_uint("alice     ", reserveToken.balanceOf(alice) / 1e9);
        emit log_named_uint("bob       ", reserveToken.balanceOf(bob) / 1e9);
        emit log_named_uint("cobra     ", reserveToken.balanceOf(cobra) / 1e9);
        emit log_named_uint("scale     ", reserveToken.scale() / 1e9);
        emit log_named_uint("reserveBal", reserveToken.reserveBalance() / 1e9);
        vm.stopPrank();
    }
}
