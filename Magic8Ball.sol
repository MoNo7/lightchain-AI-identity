// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ILightchainIdentity {
    function getIdentity(address _user) external view returns (string memory, string memory, bool);
}

interface IAIVMInferenceV2 {
    function requestInferenceV2(
        string memory modelName,
        bytes32 promptHash,
        bytes32 modelDigest,
        bytes32 detConfigHash
    ) external payable returns (bytes32 taskId);
}

contract Magic8Ball {
    address public admin;
    ILightchainIdentity public identityContract;
    IAIVMInferenceV2 public aiRouter;
    
    // Official Lightchain Testnet V2 Router
    address constant ROUTER_ADDRESS = 0x0269683E61b210d56b3D692603336fEB27B8a83a;
    
    mapping(address => string) public latestAnswer;
    mapping(bytes32 => address) public taskToUser;
    
    event OracleRequest(address indexed user, string question, bytes32 taskId);
    event OracleAnswer(address indexed user, string answer, bytes32 taskId);

    constructor(address _identityAddress) {
        admin = msg.sender;
        aiRouter = IAIVMInferenceV2(ROUTER_ADDRESS);
        identityContract = ILightchainIdentity(_identityAddress);
    }

    function getPrediction(string calldata _question) external payable {
        // 1. Identity Check
        (,, bool verified) = identityContract.getIdentity(msg.sender);
        require(verified, "DIAGNOSTIC: User not verified in Portal");
        
        // Ensure user pays the 0.15 LCAI fee to this contract
        require(msg.value >= 0.15 ether, "DIAGNOSTIC: 0.15 LCAI fee required");

        // 2. Hash the prompt for AIVM V2 Privacy
        bytes32 promptHash = keccak256(abi.encodePacked(_question));

        // 3. Request Inference with try/catch to identify Router issues
        try aiRouter.requestInferenceV2{value: 0.1 ether}(
            "llama3-8b",     // Updated model string
            promptHash,      // Privacy hash
            bytes32(0),      // default digest
            bytes32(0)       // default config
        ) returns (bytes32 taskId) {
            taskToUser[taskId] = msg.sender;
            emit OracleRequest(msg.sender, _question, taskId);
        } catch Error(string memory reason) {
            // This will show exactly why the router is reverting
            revert(string(abi.encodePacked("ROUTER_REVERT: ", reason)));
        } catch {
            revert("ROUTER_REVERT: Low-level failure or incorrect Router Address");
        }
    }

    function aivmCallback(bytes32 _taskId, string calldata _result) external {
        require(msg.sender == ROUTER_ADDRESS, "UNAUTHORIZED");
        address user = taskToUser[_taskId];
        if (user != address(0)) {
            latestAnswer[user] = _result;
            emit OracleAnswer(user, _result, _taskId);
        }
    }

    function withdraw() external {
        require(msg.sender == admin, "ONLY_ADMIN");
        payable(admin).transfer(address(this).balance);
    }

    receive() external payable {}
}