// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe fundMe;

  function setUp() external {
    fundMe = new DeployFundMe().deployFundMe();
  }

  function testMinimumAmountIsFive() public view {
    assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
  }

  function testOwnerIsSet() public view {
    assertEq(fundMe.I_OWNER(), msg.sender);
  }

  function testPriceFeedVersionIsAccurate() public view {
    uint256 expectedVersion = 4;
    if (block.chainid == 1) expectedVersion = 6;
    assertEq(fundMe.getVersion(), expectedVersion);
  }
}