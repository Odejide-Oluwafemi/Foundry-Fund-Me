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
  AggregatorV3Interface private s_priceFeed;
  address[] public s_funders;
  mapping(address funder => uint256 amount) public s_funderToAmountFunded;

  constructor(address priceFeedAddress)
  {
    s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    I_OWNER = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != I_OWNER)  revert FundMe__NotOwner();
    _;
  }

  function fund() public payable {
    if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD)
      revert FundMe__InsufficientAmountSent();
    
    if (s_funderToAmountFunded[msg.sender] == 0)  s_funders.push(msg.sender);

  }
  function withdraw() public onlyOwner {
    for (uint256 i = 0; i < s_funders.length; i++) {
      s_funderToAmountFunded[s_funders[i]] = 0;
      s_funders.pop();
    }

    s_funders = new address[](0);

    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    if (!sent) revert FundMe__FailedToWithdraw();
  }

  // Getters
  function getVersion() public view returns (uint256) {
    return PriceConverter.getVersion(s_priceFeed);
  }

  function getConversionRate() public view returns (uint256) {
    return PriceConverter.getConversionRate(1, s_priceFeed);
  }

  receive() external payable {
      fund();
  }

  fallback() external payable {
      fund();
  }
}

// Sepolia ETH/USD -> 0x694AA1769357215DE4FAC081bf1f309aDC325306