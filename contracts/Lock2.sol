// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Lock2 {
    string public host;
    address payable public owner;

    constructor() payable {
        host = "_";
        owner = payable(msg.sender);
    }

    function setHost(string memory _host) public {
        require(bytes(_host).length > 1, "host length greater than 1");
        //require(msg.sender == owner, "You aren't the owner");

        host = _host;
        owner = payable(msg.sender);
    }
}
