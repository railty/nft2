// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Sign {
    using ECDSA for bytes32;

    constructor() {

    }

    function nonce() public view returns(bytes32) {
        return keccak256(abi.encodePacked(block.number));
    }

    //the problem is nonce, which created from solidity and return to js, the next call need use this nonce, 
    //which means we need save the nonce somewhere on chain, which is too expensive
    function verifySignature(bytes memory signature) public view returns (address) {
        bytes32 msgHash = keccak256(
            //abi.encode(nonce(), msg.sender, 1234, "hello world")
            abi.encode(msg.sender, 1234, "hello world")
        );
        
        bytes32 signedMsgHash = msgHash.toEthSignedMessageHash();
        
        address addr = signedMsgHash.recover(signature);
       
        return addr;
    }
}