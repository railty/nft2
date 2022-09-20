// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct Rec { 
    address payable owner;
    uint expiredAt;
}

contract Nft2 is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;
    
    uint rate;
    //mapping(string => Rec) public hosts; 
    mapping(string => uint256) public hosts; 

    constructor(uint _rate, string memory _baseURI) ERC1155(_baseURI) {
        rate = _rate;
    }

    function mintNFT(string memory host, uint numOfDays) public payable returns (uint256) {
        require(msg.value >= numOfDays*rate, "insufficient funds");


/*
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


 */





        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId, 1, "");

        hosts[host] = newItemId;
        return newItemId;
    }

    function uri(uint256 id) public view override returns (string memory) {
        //return string(bytes.concat(bytes(super.uri(id)), "/", bytes(Strings.toString(id)), ".json"));
        return string(abi.encodePacked(super.uri(id), Strings.toString(id), ".json" ));
    }
}