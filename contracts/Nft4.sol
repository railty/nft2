// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

struct Data {
    uint16 tp;
    uint16 expiredAt;
    uint32 ipv4;
    uint128 ipv6;
    string host;
}

contract NFT4 is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint rate;
    mapping(uint256 => Data) private _datas;
    mapping(string => uint256) private _ids;
    mapping(address => uint256[]) private _owners;

    string baseUri;
    constructor(uint _rate, string memory _baseUri) ERC721("NFT4", "NFT4") {
        rate = _rate;
        baseUri = _baseUri;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(baseUri, tokenId, ".json"));
    }

    function lastTokenId() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function data(uint256 tokenId) public view virtual returns (Data memory) {
        _requireMinted(tokenId);

        Data memory _data = _datas[tokenId];
        return _data;
    }

    function token(string memory host) public view returns (uint256) {
        uint256 tokenId = _ids[host];
        return tokenId;
    }

    function tokens(address owner) public view returns (uint256[] memory) {
        return _owners[owner];
    }

    function _setData(uint256 tokenId, Data memory _data) internal virtual {
        require(_exists(tokenId), "set of nonexistent token");
        _datas[tokenId] = _data;
        _ids[_data.host] = tokenId;
    }

    function _burn(uint256 tokenId) internal virtual override {
        require(_exists(tokenId), "burn of nonexistent token");
        delete _ids[_datas[tokenId].host];
        delete _datas[tokenId];

        super._burn(tokenId);
    }

    function register(string memory host, uint numOfDays) public payable returns (uint256){
        //console.log(msg.value, numOfDays*rate);
        require(msg.value >= numOfDays*rate, "insufficient funds");

        uint256 curTokenId = _ids[host];
        if (_exists(curTokenId)){    //exist record
            Data storage curData = _datas[curTokenId];
            if (block.timestamp/60/60/24 > curData.expiredAt){
                //expired 
                if (ownerOf(curTokenId) != msg.sender){
                    //console.log("ownerOf(curTokenId) = ", ownerOf(curTokenId));
                    //this internal function can transfer the owner even the caller is not the owner
                    _transfer(ownerOf(curTokenId), msg.sender, curTokenId);
                }
                uint16 expiredAt = uint16(block.timestamp/60/60/24 + numOfDays);
                curData.expiredAt = expiredAt;
            }
            else{
                //renew
                require(msg.sender == ownerOf(curTokenId), "You aren't the owner and record is not expired yet");

                uint16 expiredAt = uint16(curData.expiredAt + numOfDays);
                curData.expiredAt = expiredAt;
            }

            return curTokenId;
        }
        else{   //new record
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            
            _safeMint(msg.sender, tokenId);

            uint16 expiredAt = uint16(block.timestamp/60/60/24 + numOfDays);
            Data memory _data = Data(65, expiredAt, 0, 0, host);   //A = 65
            _setData(tokenId, _data);

            _owners[msg.sender].push(tokenId);
            return tokenId;
        }
    }

    function _transfer(address from, address to, uint256 tokenId) internal override {
        //console.log("override _transfer");
 
        _owners[to].push(tokenId);

        uint256[] storage _tokens = _owners[from];
        for (uint i = 0; i < _tokens.length; i++){
            if (_tokens[i] == tokenId) _tokens[i] = 0;
        }

        super._transfer(from, to, tokenId);
    }

}