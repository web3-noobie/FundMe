// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    //address public sepoliaEthTOUsdAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function getPrice() internal view returns(uint256) {
        //Price of ETH in terms of USD
        //The Response uses 8 decimal places, so if eth was $2000
        //Response = 200000000000
        //Note there are no actual decimals in the returned value
        //We need to add 10 more decimals as msg.value has 1e18 and Price response is only 1e8
        
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10);

    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        //Need to divide by 1e18 as ethPrice and ethAmount are both 1e18 so you need to cancel out

        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

}
