// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mock/MockAggregatorV3Interface.sol";

abstract contract CodeConstant {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;

    address public constant ETH_SEPOLIA_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address public constant ETH_MAINNET_PRICE_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    int256 public constant MOCK_INITIAL_PRICE = 2000e8;
    uint8 public constant DECIMALS = 8;
}

contract HelperConfig is Script, CodeConstant {
    struct NetworkConfig {
        address ethUsdPriceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        activeNetworkConfig = getConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({ethUsdPriceFeedAddress: address(0)});

        if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            config.ethUsdPriceFeedAddress = ETH_SEPOLIA_PRICE_FEED;
        } else if (block.chainid == ETH_MAINNET_CHAIN_ID) {
            config.ethUsdPriceFeedAddress = ETH_MAINNET_PRICE_FEED;
        } else {
            // Local Chain (Anvil, Ganache, etc)
            if (config.ethUsdPriceFeedAddress != address(0)) {
                return config;
            }

            // Deploy Mock
            vm.startBroadcast();
            MockV3Aggregator mockAggregator = new MockV3Aggregator(DECIMALS, MOCK_INITIAL_PRICE);
            vm.stopBroadcast();

            config.ethUsdPriceFeedAddress = address(mockAggregator);
        }

        return config;
    }
}
