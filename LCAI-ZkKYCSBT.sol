// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ZkKYCSBT is ERC721 {
    using Strings for uint256;
    address public owner;
    uint256 private _tokenIds;
    string private _base64Image; // Stored on-chain via constructor

    mapping(address => bool) public hasSBT;
    mapping(address => bool) public isAdmin;

    // Passing the image string at deployment time avoids compiler overflow
    constructor(string memory base64Image) ERC721("Lightchain ZK Identity", "LCAI-ZK") {
        owner = msg.sender;
        isAdmin[msg.sender] = true;
        _base64Image = base64Image;
    }

    function mintIdentity() external {
        require(!hasSBT[msg.sender], "LCAI: Asset already exists");
        _tokenIds++;
        hasSBT[msg.sender] = true;
        _safeMint(msg.sender, _tokenIds);
    }

    function addAdmin(address _admin) external {
        require(msg.sender == owner, "LCAI: Not Owner");
        isAdmin[_admin] = true;
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        
        string memory description = string(abi.encodePacked(
            "Verified Lightchain AI Testnet Identity #", 
            tokenId.toString()
        ));

        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "Lightchain AI ZK-Pass", ',
            '"description": "', description, '", ',
            '"image": "data:image/png;base64,', _base64Image, '"}'
        ))));
        
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0) || to == address(0), "LCAI: Asset is Soulbound");
        return super._update(to, tokenId, auth);
    }
}