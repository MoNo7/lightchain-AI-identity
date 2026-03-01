// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract LightchainIdentity {
    // Mapping to allow multiple authorized "Admins" (e.g., You and the SBT Contract)
    mapping(address => bool) public isAdmin;

    struct UserProfile {
        string username;
        string did;
        bool isVerified;
        bool exists;
    }

    mapping(address => UserProfile) public profiles;

    event AdminAdded(address indexed newAdmin);
    event IdentityVerified(address indexed userAddress);

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Caller is not an authorized admin");
        _;
    }

    constructor() {
        isAdmin[msg.sender] = true; // You are the first admin
    }

    // THIS IS THE FUNCTION YOU WERE MISSING
    function addAdmin(address _newAdmin) external onlyAdmin {
        isAdmin[_newAdmin] = true;
        emit AdminAdded(_newAdmin);
    }

    function verifyIdentity(address userAddress) external onlyAdmin {
        profiles[userAddress].isVerified = true;
        emit IdentityVerified(userAddress);
    }

    function isVerified(address userAddress) external view returns (bool) {
        return profiles[userAddress].isVerified;
    }
}