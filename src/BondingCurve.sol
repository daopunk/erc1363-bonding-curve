// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/ERC20.sol";
import "@openzeppelin/access/Ownable.sol";
import "src/Bancor/BancorFormula.sol";

contract BondingCurve is ERC20("Futuro", "FTR"), BancorFormula, Ownable {
    uint256 public poolBalance;
    uint32 public reserveRatio;

    event Mint(uint256 amountMinted, uint256 totalCost);
    event Withdraw(uint256 amountWithdrawn, uint256 reward);

    /*
    * - Front-running attacks are currently mitigated by the following mechanisms:
    * TODO - minimum return argument for each conversion provides a way to define a minimum/maximum price for the transaction
    * - gas price limit prevents users from having control over the order of execution
    */
    uint256 public gasPrice = 1 * 10 ** 18; // maximum gas price for bancor transactions in wei

    // verifies that the gas price is lower than the universal limit
    modifier validGasPrice() {
        require(tx.gasprice <= gasPrice, "BondingCurve: Gas price exceeds max allowed");
        _;
    }

    receive() external payable {
        buy();
    }

    fallback() external payable {
        buy();
    }

    function buy() public payable validGasPrice returns (bool) {
        require(msg.value > 0);
        uint256 supply = totalSupply();
        uint256 tokensToMint = calculatePurchaseReturn(supply, poolBalance, reserveRatio, msg.value);
        _mint(msg.sender, tokensToMint);
        poolBalance += msg.value;
        emit Mint(tokensToMint, msg.value);
        return true;
    }

    function sell(uint256 sellAmount) public validGasPrice returns (bool) {
        require(sellAmount > 0 && balanceOf(msg.sender) >= sellAmount);
        uint256 supply = totalSupply();
        uint256 ethAmount = calculateSaleReturn(supply, poolBalance, reserveRatio, sellAmount);
        payable(msg.sender).transfer(ethAmount);
        poolBalance -= ethAmount;
        _burn(msg.sender, sellAmount);
        emit Withdraw(sellAmount, ethAmount);
        return true;
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
