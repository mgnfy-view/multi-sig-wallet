// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TestNFT is ERC721URIStorage, Ownable {
    string private nftUri;
    uint256 private tokenId;

    constructor(string memory _nftUri) ERC721("TestNFT", "TNFT") {
        nftUri = _nftUri;
        tokenId = 0;
    }

    function mintNFT(address _to) external onlyOwner {
        tokenId++;
        _safeMint(_to, tokenId, "");
        _setTokenURI(tokenId, nftUri);
    }
}
