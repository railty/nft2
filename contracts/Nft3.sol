// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct Rec { 
    uint256 tokenId;
    address owner;
    uint expiredAt;
}

contract Nft3 is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(uint256 => string) private _tokenURIs;
    
    uint rate;
    //hostname to record; 
    mapping(string => Rec) public hosts; 

    //token id to hostname
    mapping(uint => string) public ids; 

    constructor(uint _rate) ERC721("NFT3", "NFT3") {
        rate = _rate;
    }

    function _mintNFT() internal returns (uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
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
                _burn(hosts[host].tokenId);
                newItemId = _mintNFT();
                hosts[host] = Rec(newItemId, msg.sender, block.timestamp + numOfDays*24*60*60);
            }
            else{
                require(msg.sender == hosts[host].owner, "You aren't the owner and record is not expired yet");

                _burn(hosts[host].tokenId);
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
}