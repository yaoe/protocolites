// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Protocolites.sol";
import "solady/auth/Ownable.sol";

contract ProtocoliteFactory is Ownable {
    
    event ProtocoliteSpawned(address indexed spawner, address indexed newProtocolite, uint256 parentTokenId);
    
    address public renderer;
    uint256 public spawnCounter;
    
    mapping(address => address[]) public spawnedByAddress;
    mapping(address => bool) public isProtocolite;
    
    constructor() {
        _initializeOwner(msg.sender);
    }
    
    function setRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
    }
    
    function spawnProtocolite(uint256 parentTokenId, address parentContract, address spawner) external returns (address) {
        require(isProtocolite[parentContract], "Invalid parent contract");
        require(msg.sender == parentContract, "Only parent contract can spawn");
        require(Protocolites(payable(parentContract)).ownerOf(parentTokenId) != address(0), "Parent token does not exist");
        
        // Create new Protocolite contract
        Protocolites newProtocolite = new Protocolites();
        address newAddress = address(newProtocolite);
        
        // Set renderer
        newProtocolite.setRenderer(renderer);
        
        // Transfer ownership to the spawner
        newProtocolite.transferOwnership(spawner);
        
        // Track the spawn
        spawnedByAddress[spawner].push(newAddress);
        isProtocolite[newAddress] = true;
        spawnCounter++;
        
        emit ProtocoliteSpawned(spawner, newAddress, parentTokenId);
        
        return newAddress;
    }
    
    function registerProtocolite(address protocolite) external onlyOwner {
        isProtocolite[protocolite] = true;
    }
    
    function getSpawnedByAddress(address spawner) external view returns (address[] memory) {
        return spawnedByAddress[spawner];
    }
}