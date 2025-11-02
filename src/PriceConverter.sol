// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getVersion(AggregatorV3Interface priceFeed) external view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice(AggregatorV3Interface priceFeed) public view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer) * 1e10;
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) public view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }
}
