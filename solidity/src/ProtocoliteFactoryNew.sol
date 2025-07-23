// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ProtocoliteInfection.sol";
import "solady/auth/Ownable.sol";

contract ProtocoliteFactoryNew is Ownable {
    
    event InfectionContractDeployed(uint256 indexed parentTokenId, address indexed infectionContract, uint256 parentDna);
    
    address public renderer;
    uint256 public deployedCount;
    
    // Track all deployed infection contracts
    mapping(uint256 => address) public infectionContracts; // parentTokenId => infection contract
    address[] public allInfectionContracts;
    
    constructor() {
        _initializeOwner(msg.sender);
    }
    
    function setRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
    }
    
    function deployInfectionContract(uint256 parentTokenId, uint256 parentDna) external returns (address) {
        // Only allow the master contract to deploy infection contracts
        require(msg.sender == owner(), "Only master can deploy");
        require(infectionContracts[parentTokenId] == address(0), "Infection contract already exists");
        
        // Deploy new infection contract
        ProtocoliteInfection infection = new ProtocoliteInfection(parentTokenId, parentDna, renderer);
        address infectionAddress = address(infection);
        
        // Transfer ownership to the caller (master contract)
        infection.transferOwnership(msg.sender);
        
        // Track the deployment
        infectionContracts[parentTokenId] = infectionAddress;
        allInfectionContracts.push(infectionAddress);
        deployedCount++;
        
        emit InfectionContractDeployed(parentTokenId, infectionAddress, parentDna);
        
        return infectionAddress;
    }
    
    function getInfectionContract(uint256 parentTokenId) external view returns (address) {
        return infectionContracts[parentTokenId];
    }
    
    function getAllInfectionContracts() external view returns (address[] memory) {
        return allInfectionContracts;
    }
    
    function getDeployedCount() external view returns (uint256) {
        return deployedCount;
    }
}