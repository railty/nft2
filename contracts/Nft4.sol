// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

struct Data {
    uint16 tp;
    uint16 expired_at;
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

    constructor(uint _rate) ERC721("NFT4", "NFT4") {
        rate = _rate;
    }

    function data(uint256 tokenId) public view virtual returns (Data memory) {
        _requireMinted(tokenId);

        Data memory _data = _datas[tokenId];
        return _data;
    }

    function _setData(uint256 tokenId, Data memory _data) internal virtual {
        require(_exists(tokenId), "set of nonexistent token");
        _datas[tokenId] = _data;
        _ids[_data.host] = tokenId;
    }

    function _burn(uint256 tokenId) internal virtual override {

        if (_datas[tokenId].tp != 0) {
            delete _ids[_datas[tokenId].host];
            delete _datas[tokenId];
        }

        super._burn(tokenId);
    }

    function safeMint(string memory host, uint numOfDays) public payable{
        //console.log(msg.value, numOfDays*rate);
        require(msg.value >= numOfDays*rate, "insufficient funds");

        if (_datas[_ids[host]].expired_at > 0){    //exist record
        }
        else{   //new record
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(msg.sender, tokenId);

            uint16 expired_at = uint16(block.timestamp/60/60/24 + numOfDays);
            Data memory _data = Data(65, expired_at, 0, 0, host);   //A = 65
            _setData(tokenId, _data);
        }
    }

}