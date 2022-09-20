// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

struct Rec { 
    string host;
    address payable owner;
    uint expiredAt;
}

contract Lock2 {
    uint rate;
    mapping(string => Rec) public hosts; 

    constructor(uint _rate) {
        rate = _rate;
    }

    function setHost(string memory _host, uint numOfDays) public payable {
        require(bytes(_host).length > 1, "host length must be greater than 1");
        //console.log(msg.value, numOfDays*rate);
        require(msg.value >= numOfDays*rate, "insufficient funds");

        if (hosts[_host].expiredAt > 0){    //exist record
            console.log("existing record");

            if (block.timestamp > hosts[_host].expiredAt){
                hosts[_host] = Rec(_host, payable(msg.sender), block.timestamp + numOfDays*24*60*60);
            }
            else{
                require(msg.sender == hosts[_host].owner, "You aren't the owner and record is not expired yet");
                hosts[_host].expiredAt = hosts[_host].expiredAt + numOfDays*24*60*60;
            }
        }
        else{
            console.log("new record");
            hosts[_host] = Rec(_host, payable(msg.sender), block.timestamp + numOfDays*24*60*60);
        }
    }

    function getTime() public view returns(uint) {
        return block.timestamp;
    }
}
