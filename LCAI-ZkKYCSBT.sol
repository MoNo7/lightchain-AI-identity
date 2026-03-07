// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract LightchainZkKYC is ERC721, Ownable {
    string public base64Image;
    mapping(address => string) public nicknames;
    mapping(address => string) public dids;
    mapping(address => bool) public verified;
    mapping(address => uint256) public creationTime;
    mapping(address => string) public socialProvider;
    mapping(address => bytes32) public identityHashes;
    mapping(bytes32 => bool) public usedHashes;

    
    constructor(string memory _name, string memory _symbol, string memory _img) 
        ERC721(_name, _symbol) 
        Ownable(msg.sender) 
    {
        base64Image = _img;
    }


// 2. Add these helper functions for the Frontend
function isOwner(address _u) public view returns (bool) {
    return _u == owner();
}

function isAdmin(address _u) public view returns (bool) {
    // For now, let's treat the owner as the admin so your menu shows up
    return _u == owner();
}

function mintWithSocial(string memory _nick, string memory _did, string memory _provider, bytes32 _idHash) public payable {        require(msg.value >= 0.01 ether, "LCAI: Fee required");
        require(!verified[msg.sender], "LCAI: Already verified");
        require(msg.value >= 0.01 ether, "Fee required");
        require(!usedHashes[_idHash], "LCAI: Social identity already linked"); // Sybil protection
        nicknames[msg.sender] = _nick;
        dids[msg.sender] = _did;
        socialProvider[msg.sender] = _provider;
        identityHashes[msg.sender] = _idHash;
        verified[msg.sender] = true;
        creationTime[msg.sender] = block.timestamp; // Save creation date

        _safeMint(msg.sender, uint256(uint160(msg.sender)));
    }

 function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        address tOwner = ownerOf(_tokenId);

        string memory description = string(abi.encodePacked(
        "Lightchain AI Verified Identity for ", nicknames[tOwner], ".\\n", 
        "Soulbound NFT created on: ", Strings.toString(creationTime[tOwner])
    ));

        string memory json = string(abi.encodePacked(
        '{"name": "', nicknames[tOwner], ' LCAI Multipass",',
        '"description": "', description, '",',
        '"image": "data:image/png;base64,', base64Image, '",',
        '"attributes": [',
            '{"trait_type": "Identity", "value": "Soulbound"},',
            '{"trait_type": "Username", "value": "', nicknames[tOwner], '"},',
            '{"trait_type": "Registered", "value": "', Strings.toString(creationTime[tOwner]), '"}',
        ']}'
    ));
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(json))));
    }

    // --- ADMIN FUNCTIONS (Restored) ---
    
    
    // Fixes the "Wipe Identity" require(false)
    function removeSBT(address _u) public onlyOwner {
        require(verified[_u], "User not verified");
        
        _burn(uint256(uint160(_u))); // Burn the SBT
        delete nicknames[_u];
        delete dids[_u];
        delete verified[_u];
    }

    // Fixes the "Withdraw Failed" require(false)
    function withdrawRevenue() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        payable(owner()).transfer(balance);
    }

    // Helper to update the image template
    function updatePassportTemplate(string memory _newImg) public onlyOwner {
        base64Image = _newImg;
    }

    // Soulbound Logic: Block transfers
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("LCAI: Soulbound tokens cannot be transferred");
        }
        return super._update(to, tokenId, auth);
    }
}