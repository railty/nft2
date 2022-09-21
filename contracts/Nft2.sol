// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct Rec { 
    uint256 tokenId;
    address owner;
    uint expiredAt;
}

contract Nft2 is ERC1155, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;
    
    uint rate;
    //mapping(string => Rec) public hosts; 
    mapping(string => Rec) public hosts; 

    constructor(uint _rate, string memory _baseURI) ERC1155(_baseURI) {
        rate = _rate;
    }

    function _mintNFT() internal returns (uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId, 1, "");
        return newItemId;
    }

    function mintNFT(string memory host, uint numOfDays) public payable returns (uint256) {
        require(bytes(host).length > 1, "host length must be greater than 1");        
        //console.log(msg.value, numOfDays*rate);
        require(msg.value >= numOfDays*rate, "insufficient funds");

        uint256 newItemId = 0;
        if (hosts[host].expiredAt > 0){    //exist record
            console.log("existing record");

            if (block.timestamp > hosts[host].expiredAt){
                //expired 
                _burn(hosts[host].owner, hosts[host].tokenId, 1);
                newItemId = _mintNFT();
                hosts[host] = Rec(newItemId, msg.sender, block.timestamp + numOfDays*24*60*60);
            }
            else{
                require(msg.sender == hosts[host].owner, "You aren't the owner and record is not expired yet");

                _burn(hosts[host].owner, hosts[host].tokenId, 1);
                newItemId = _mintNFT();
                hosts[host] = Rec(newItemId, msg.sender, hosts[host].expiredAt + numOfDays*24*60*60);
            }
        }
        else{
            console.log("new record");

            newItemId = _mintNFT();
            hosts[host] = Rec(newItemId, msg.sender, block.timestamp + numOfDays*24*60*60);
        }

        return newItemId;
    }

    function uri(uint256 id) public view override returns (string memory) {
        //return string(bytes.concat(bytes(super.uri(id)), "/", bytes(Strings.toString(id)), ".json"));
        return string(abi.encodePacked(super.uri(id), Strings.toString(id), ".json" ));
    }
}