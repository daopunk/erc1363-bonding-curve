// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";
import "src/Bancor/BancorFormula.sol";

contract BondERC20 is ERC20("Reserve", "RSV"), BancorFormula, Ownable {
    uint256 public scale = 1e18;
    uint256 public reserveBalance = 10 * scale;
    uint32 public reserve_ratio = 900_000;

    event Mint(uint256 amountMinted, uint256 totalCost);
    event Withdraw(uint256 amountWithdrawn, uint256 reward);

    constructor() {
        _mint(address(this), 1 * scale);
    }

    /*
    * - Front-running attacks are currently mitigated by the following mechanisms:
    * TODO - minimum return argument for each conversion provides a way to define a minimum/maximum price for the transaction
    * - gas price limit prevents users from having control over the order of execution
    */
    uint256 public gasPrice = 1 * 10 ** 18; // maximum gas price for bancor transactions in wei

    // verifies that the gas price is lower than the universal limit
    modifier validGasPrice() {
        // require(tx.gasprice <= gasPrice, "BondingCurve: Gas price exceeds max allowed");
        _;
    }

    receive() external payable {
        buy();
    }

    fallback() external payable {
        buy();
    }

    function buy() public payable validGasPrice returns (uint256 tokensToMint) {
        require(msg.value > 0, "BondERC20: Msg.value cannot be zero");

        tokensToMint = calculatePurchaseReturn(totalSupply(), reserveBalance, reserve_ratio, msg.value);
        reserveBalance += msg.value;
        _mint(msg.sender, tokensToMint);

        emit Mint(tokensToMint, msg.value);
    }

    function sell(uint256 sellAmount) public validGasPrice returns (uint256 ethAmount) {
        require(
            sellAmount > 0 && balanceOf(msg.sender) >= sellAmount,
            "BondERC20: sell amount cannot be greater than balance"
        );

        ethAmount = calculateSaleReturn(totalSupply(), reserveBalance, reserve_ratio, sellAmount);
        reserveBalance -= ethAmount;
        _burn(msg.sender, sellAmount);
        payable(msg.sender).transfer(ethAmount);

        emit Withdraw(sellAmount, ethAmount);
    }

    /**
     * @dev Allows the owner to update the gas price limit
     * @param _gasPrice The new gas price limit
     */
    function setGasPrice(uint256 _gasPrice) external onlyOwner {
        require(_gasPrice > 0);
        gasPrice = _gasPrice;
    }
}
