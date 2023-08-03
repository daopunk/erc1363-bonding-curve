// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/tokens/CensorERC20.sol";
import "src/tokens/SanctionERC20.sol";
import "src/tokens/BondERC20.sol";
import "src/PaymentEscrow.sol";

// forge test --match-contract Contract

contract TestHelper is Test {
    CensorERC20 public censorToken;
    SanctionERC20 public sanctionToken;
    BondERC20 public reserveToken;
    PaymentEscrow public escrow;

    address public alice = address(0xa11ce);
    address public bob = address(0xb0b);
    address public cobra = address(0xc0b7a);

    function setUp() public virtual {
        censorToken = new CensorERC20(alice);
        sanctionToken = new SanctionERC20([alice, address(this)]);
        reserveToken = new BondERC20();
        escrow = new PaymentEscrow();

        mintEther();
        mintAdmin();
    }

    function mintAdmin() public {
        sanctionToken.mint(alice, 1000 ether);
        sanctionToken.mint(address(this), 1000 ether);
    }

    function mintEther() public {
        vm.deal(alice, 10000 ether);
        vm.deal(bob, 10000 ether);
        vm.deal(cobra, 10000 ether);
    }
}
