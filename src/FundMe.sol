// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
  error FundMe__InsufficientAmountSent();
  error FundMe__NotOwner();
  error FundMe__FailedToWithdraw();

  using PriceConverter for uint256;

  uint256 public constant MINIMUM_USD = 5e18;
  address public immutable I_OWNER;
  AggregatorV3Interface private sPriceFeed;
  address[] private sFunders;
  mapping(address funder => uint256 amount) public sFunderToAmountFunded;

  constructor(address priceFeedAddress) {
    sPriceFeed = AggregatorV3Interface(priceFeedAddress);
    I_OWNER = msg.sender;
  }

  modifier onlyOwner() {
    _onlyOwner();
    _;
  }
    
  function _onlyOwner() internal view{
    require(msg.sender == I_OWNER, "Only Owner can call this function!");
  }

  function fund() public payable {
    if (msg.value.getConversionRate(sPriceFeed) < MINIMUM_USD) {
      revert FundMe__InsufficientAmountSent();
    }

    if (sFunderToAmountFunded[msg.sender] == 0) sFunders.push(msg.sender);
    sFunderToAmountFunded[msg.sender] += msg.value;
  }

  function withdraw() public onlyOwner {
    for (uint256 i = 0; i < sFunders.length; i++) {
      sFunderToAmountFunded[sFunders[i]] = 0;
      sFunders.pop();
    }

    sFunders = new address[](0);

    (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
    if (!sent) revert FundMe__FailedToWithdraw();
  }

  // Getters
  function getVersion() external view returns (uint256) {
    return PriceConverter.getVersion(sPriceFeed);
  }

  function getConversionRate() external view returns (uint256) {
    return PriceConverter.getConversionRate(1, sPriceFeed);
  }

  function getFunder(uint256 index) external view returns (address) {
    return sFunders[index];
  }

  function getFunderAmount(address funder) external view returns (uint256) {
    return sFunderToAmountFunded[funder];
  }

  function getFundersArrayLength() external view returns (uint256) {
    return sFunders.length;
  }

  receive() external payable {
    fund();
  }

  fallback() external payable {
    fund();
  }
}

// Sepolia ETH/USD -> 0x694AA1769357215DE4FAC081bf1f309aDC325306