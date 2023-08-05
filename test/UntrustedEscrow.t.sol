// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "test/TestHelper.sol";

contract UntrustedEscrow is TestHelper {
    function testBuy() public {
        vm.startPrank(alice);
        sanctionToken.approve(address(escrow), 100 ether);
        escrow.deposit(address(sanctionToken), 100 ether, bob);
        assertEq(sanctionToken.balanceOf(address(escrow)), 100 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("Time lock is valid.");
        escrow.withdraw(1);
        vm.stopPrank();

        vm.warp(4 days);

        vm.startPrank(bob);
        escrow.withdraw(1);
        assertEq(sanctionToken.balanceOf(bob), 100 ether);
        vm.stopPrank();
    }
}
