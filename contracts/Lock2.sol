// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Lock2 {
    string public host;

    constructor() payable {
        console.log("constructor of Lock2");
        host = "_";
    }

    function setHost(string memory _host) public {
        console.log("length of ", _host, " is ", bytes(_host).length);
        require(bytes(_host).length > 1, "host length greater than 1");
        //require(msg.sender == owner, "You aren't the owner");

        host = _host;
    }
}
