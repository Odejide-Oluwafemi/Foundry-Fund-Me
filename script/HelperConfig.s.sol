// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mock/MockAggregatorV3Interface.sol";

abstract contract CodeConstant {
  uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
  uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
}

contract HelperConfig is Script, CodeConstant {
  struct NetworkConfig {
    address ethUsdPriceFeedAddress;
  }

  NetworkConfig public activeNetworkConfig;

  constructor() {
    activeNetworkConfig = getConfig();
  }

  function getConfig() public view returns (NetworkConfig memory) {
    NetworkConfig memory config = NetworkConfig({ethUsdPriceFeedAddress: address(0)});

    if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
      config.ethUsdPriceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    }
    else if (block.chainid == ETH_MAINNET_CHAIN_ID) {
      config.ethUsdPriceFeedAddress = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    }
    else
    {
      // Deploy Mock

    }

    return config;
  }
}