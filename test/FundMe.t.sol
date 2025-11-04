// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 private constant FUND_AMOUNT = 1 ether;

    function setUp() external {
        fundMe = new DeployFundMe().deployFundMe();
        vm.deal(USER, STARTING_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
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

    function testFundFailsWithInsufficientAmount() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedArray() public {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        assertEq(fundMe.getFunder(0), USER);
    }

    function testFundUpdatesFunderBalanceInMapping() public funded {
        assertEq(fundMe.getFunderAmount(USER), FUND_AMOUNT);
    }

    function testFunderOnlyGetsAddedToArrayOnceWhenFundedTwice() public funded funded {
        assertEq(fundMe.getFundersArrayLength(), 1);
        assertEq(fundMe.getFunderAmount(USER), FUND_AMOUNT * 2);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
}
