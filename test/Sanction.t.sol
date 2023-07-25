// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "test/TestHelper.sol";

contract Sanction is TestHelper {
    function testAccessControl() public {
        vm.prank(alice);
        sanctionToken.blacklistAdd(cobra);
    }

    function testAccessControlFail() public {
        vm.prank(bob);
        vm.expectRevert("Not authorized");
        sanctionToken.blacklistAdd(cobra);
    }

    function testTransfer() public {
        vm.prank(alice);
        sanctionToken.transfer(bob, 50 ether);
    }

    function testTransferFail() public {
        vm.prank(alice);
        sanctionToken.blacklistAdd(bob);
        vm.expectRevert("Receiver blacklisted");
        sanctionToken.transfer(bob, 50 ether);
    }

    function testReceive() public {
        vm.prank(alice);
        sanctionToken.transfer(bob, 50 ether);
        vm.prank(bob);
        sanctionToken.transfer(cobra, 50 ether);
    }

    function testReceiveFail() public {
        vm.prank(alice);
        sanctionToken.transfer(bob, 50 ether);
        sanctionToken.blacklistAdd(bob);
        vm.prank(bob);
        vm.expectRevert("Sender blacklisted");
        sanctionToken.transfer(cobra, 50 ether);
    }
}
