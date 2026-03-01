// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IZkKYC {
    function hasSBT(address user) external view returns (bool);
    function isAdmin(address user) external view returns (bool);
}

contract AIArtStudio {
    address public owner;
    IZkKYC public identityContract;
    mapping(address => bool) public manualVerified;

    // Added modelDigest to match Native LCAI AIVM V2 standards
    event ArtGenerated(
        address indexed user, 
        string prompt, 
        bytes32 modelDigest, 
        uint256 fee
    );

    constructor(address _identityContractAddr) {
        owner = msg.sender;
        identityContract = IZkKYC(_identityContractAddr);
        manualVerified[msg.sender] = true; 
    }

    function setVerification(address user, bool status) external {
        require(msg.sender == owner || identityContract.isAdmin(msg.sender), "LCAI: Unauthorized");
        manualVerified[user] = status;
    }

    // Default modelDigest for SDXL-Turbo on Lightchain AIVM
    bytes32 public constant DEFAULT_MODEL = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;

    function generateArt(string calldata prompt) external payable {
        require(msg.value >= 0.25 ether, "LCAI: 0.25 LCAI Fee Required");
        require(identityContract.hasSBT(msg.sender) || manualVerified[msg.sender], "LCAI: KYC Required");
        
        // Emitting the native AIVM anchor signal
        emit ArtGenerated(msg.sender, prompt, DEFAULT_MODEL, msg.value);
    }

    function withdraw() external {
        require(msg.sender == owner, "LCAI: Not Owner");
        uint256 amount = address(this).balance;
        require(amount > 0, "LCAI: Vault Empty");
        
        (bool success, ) = owner.call{value: amount}("");
        require(success, "LCAI: Transfer Failed");
    }
}