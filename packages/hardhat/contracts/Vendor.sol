pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address user, uint256 amountOfEth, uint256 amount);

  uint256 public constant tokensPerEth = 100;

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:

  function buyTokens() public payable {
    uint256 amountOfETH = msg.value ;
    require(amountOfETH > 0 , "Insufficeint balance to buy the tokens. ");

    uint256 tokensToTransfer = amountOfETH * tokensPerEth;
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= tokensToTransfer, "Vendor does not have enough tokens to send");

    yourToken.transfer(msg.sender, tokensToTransfer);

    emit BuyTokens(msg.sender, amountOfETH, tokensToTransfer);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw() public onlyOwner {
    // Validate the vendor has ETH to withdraw
    uint256 vendorBalance = address(this).balance;
    require(vendorBalance > 0, "Vendor does not have any ETH to withdraw");

    // Send ETH
    address owner = msg.sender;
    (bool sent, ) = owner.call{value: vendorBalance}("");
    require(sent, "Failed to withdraw");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:
function sellTokens(uint256 amount) public {
    // Validate token amount
    require(amount > 0, "Must sell a token amount greater than 0");

    // Validate the user has the tokens to sell
    address user = msg.sender;
    uint256 userBalance = yourToken.balanceOf(user);
    require(userBalance >= amount, "User does not have enough tokens");

    // Validate the vendor has enough ETH
    uint256 amountOfEth = amount / tokensPerEth;

    // Transfer tokens
    (bool sent) = yourToken.transferFrom(user, address(this), amount);
    require(sent, "Failed to transfer tokens");

    // Transfer ETH
    (bool ethSent, ) = user.call{value: amountOfEth }("");
    require(ethSent, "Failed to send back eth");

    // Emit sell event
    emit SellTokens(user, amountOfEth, amount);
  }
}
