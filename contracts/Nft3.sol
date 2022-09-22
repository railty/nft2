// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

struct Rec { 
    uint256 tokenId;
    uint expiredAt;
}

contract Nft3 is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using ECDSA for bytes32;
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
                delete ids[hosts[host].tokenId];
                _burn(hosts[host].tokenId);

                newItemId = _mintNFT();
                hosts[host] = Rec(newItemId, block.timestamp + numOfDays*24*60*60);
                ids[newItemId] = host;
            }
            else{
                require(msg.sender == ownerOf(hosts[host].tokenId), "You aren't the owner and record is not expired yet");

                delete ids[hosts[host].tokenId];
                _burn(hosts[host].tokenId);
                newItemId = _mintNFT();
                hosts[host] = Rec(newItemId, hosts[host].expiredAt + numOfDays*24*60*60);
                ids[newItemId] = host;
            }
        }
        else{
            console.log("new record");

            newItemId = _mintNFT();
            hosts[host] = Rec(newItemId, block.timestamp + numOfDays*24*60*60);
            ids[newItemId] = host;
        }

        return newItemId;
    }

    function lastId() public view returns (uint256) {
        return _tokenIds.current();    
    }

    function verify(bytes32 smsg, bytes memory sig) public view returns (address) {
        
        address x = smsg.recover(sig);
        console.log("x=", x);
        return x;
    }


    function messageHash(bytes memory message) public pure returns(bytes32) {
        return keccak256(message);
    }

    function ethSignedHash(bytes32 hMessage) public pure returns(bytes32) {
        return hMessage.toEthSignedMessageHash();
    }

    function recover(bytes32 hash, bytes memory signature) public pure returns(address) {
        return hash.recover(signature);
    }

    function bytes32ToBytes(bytes32 _bytes32) internal pure returns (bytes memory){
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return bytesArray;
    }

    function nonce() public view returns(bytes32) {
        return keccak256(abi.encodePacked(block.number));
    }

    //the problem is nonce, which created from solidity and return to js, the next call need use this nonce, 
    //which means we need save the nonce somewhere on chain, which is too expensive
    function verify(bytes memory signature) public view returns (address) {
        bytes32 msgHash = keccak256(
            abi.encode(nonce(), msg.sender, 1234, "hello world")
        );
        
        console.log("msgHash=", string(bytes32ToBytes(msgHash)));

        bytes32 signedMsgHash = msgHash.toEthSignedMessageHash();
        
        console.log("msgHash=", string(bytes32ToBytes(signedMsgHash)));

        address addr = signedMsgHash.recover(signature);

        
        return addr;
    }
}