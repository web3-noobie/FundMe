// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    //This will assign all functions in PriceConverter to all uint256, almost making uint256 like a new class
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; //5e18 is $5 plus 18 zeros -> 5 * 1e18

    //Create an array of addresses to store all the funders
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }
    
    function fund() public payable {
        //payable allows users to send money to a contract
        //require msg.value forces a user to send a value in the transaction or else it will revert the entire function call
        //so you should have all your requires at the beginning
        
        //Since we are using PriceConverter library, we can call getConversationRate on msg.value since it is a uint256
        //The msg.value type will be pass into the library function as the first variable even though its not specified here in ()
        //if you had a value in (), that would be the second value passed to the library function, assuming it is able to accept
        
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough wei");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }


    function withdraw() public onlyOwner {
        
        //reset the addressToAmountFunded mapping to 0
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        
        //reset the funders address array to 0
        funders = new address[](0);

        /*
        //There are 3 ways to move funds from a contract: transfer, send, call
        
        //Transfer
        //we need to type cast msg.sender (which is type address) to type payable. If this line fails, it returns an error code and is capped at 2300 gas
        payable(msg.sender).transfer(address(this).balance);

        //Send, instead returns a bool and is also capped at 2300 gas
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed");
        */

        //Call, a low level powerful function that will create an transaction through itself by calling the function
        //bytes memory dataReturned is commented but it is to identify that two values are returned from the call function
        //Call is the recommended way to send you block native token
        (bool callSuccess, /*bytes memory dataReturned*/) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");

    }

    modifier onlyOwner() {
        //order of the _ matters. You want this code first, then _ allows the rest of the code where the modifier was placed
        
        //This custom error below is new to solidity, instead of using require
        if(msg.sender != i_owner) revert NotOwner();
        
        //We are using error NotOwner() declared above, otherwise use require below which is more common
        //require(msg.sender == i_owner, "Not owner");
        _;
    }

    //only called if there is no transaction data
    receive() external payable  {
        fund();
    }

    //difference between receive and fallback, is fallback will be called if there is transaction data
    fallback() external payable { 
        fund();
    }
}
