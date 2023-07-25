// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "test/TestHelper.sol";

contract Censor is TestHelper {
    function testTransfer() public {
        vm.startPrank(alice);
        censorToken.mint(alice, 1000 ether);
        censorToken.transfer(bob, 50 ether);
    }

    function testTransferFrom() public {
        vm.startPrank(alice);
        censorToken.mint(alice, 1000 ether);
        censorToken.approve(bob, 50 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        censorToken.transferFrom(alice, cobra, 10 ether);
    }

    function testTransferFromFail() public {
        vm.startPrank(bob);
        vm.expectRevert("ERC20: insufficient allowance");
        censorToken.transferFrom(alice, cobra, 50 ether);
    }

    function testTransferFromCentralAuth() public {
        vm.startPrank(alice);
        censorToken.mint(bob, 1000 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        censorToken.transfer(cobra, 100 ether);
        vm.stopPrank();

        vm.startPrank(alice);
        censorToken.transferFromCensor(cobra, alice, 100 ether);
        vm.stopPrank();
    }

    function testTransferFromCentralAuthFail() public {
        vm.startPrank(alice);
        censorToken.mint(bob, 1000 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        censorToken.transfer(cobra, 100 ether);
        vm.expectRevert("Not authorized");
        censorToken.transferFromCensor(cobra, alice, 100 ether);
        vm.stopPrank();
    }
}
