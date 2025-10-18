// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/LibString.sol";
import "./ProtocoliteInfection.sol";
import "./ProtocoliteFactoryNew.sol";
import "./ProtocolitesRender.sol";

contract ProtocolitesMaster is ERC721, Ownable {

    uint256 private _currentTokenId;

    ProtocoliteFactoryNew public factory;
    ProtocolitesRender public renderer;
    
    // TokenId => Infection contract address
    mapping(uint256 => address) public infectionContracts;
    
    // Track parent NFT data
    struct ParentData {
        uint256 dna;
        uint256 birthBlock;
        address infectionContract;
    }
    
    mapping(uint256 => ParentData) public parentData;
    
    event ParentSpawned(uint256 indexed tokenId, address indexed owner, address infectionContract);
    event InfectionTriggered(uint256 indexed parentId, address indexed victim, address infectionContract);
    
    constructor() {
        _initializeOwner(msg.sender);
    }
    
    function name() public pure override returns (string memory) {
        return "Protocolites";
    }
    
    function symbol() public pure override returns (string memory) {
        return "PROTO";
    }
    
    function setFactory(address _factory) external onlyOwner {
        factory = ProtocoliteFactoryNew(_factory);
    }
    
    function setRenderer(address _renderer) external onlyOwner {
        renderer = ProtocolitesRender(_renderer);
    }

    // Dynamic spawn cost: 0.001 ETH on Sepolia, 0.01 ETH on mainnet
    function getSpawnCost() public view returns (uint256) {
        // Sepolia testnet
        if (block.chainid == 11155111) {
            return 0.001 ether;
        }
        // Mainnet and all other networks
        return 0.01 ether;
    }

    // Receive function: handles ETH transactions
    receive() external payable {
        if (msg.value >= getSpawnCost()) {
            _spawnNewParent(msg.sender);
        } else {
            // Trigger random infection
            _triggerRandomInfection(msg.sender);
        }
    }
    
    // Fallback for function calls with tokenId
    fallback() external payable {
        require(msg.value == 0, "Use receive() for paid spawns");
        
        // Try to decode tokenId from calldata
        if (msg.data.length >= 32) {
            uint256 tokenId = abi.decode(msg.data, (uint256));
            _triggerInfection(tokenId, msg.sender);
        } else {
            _triggerRandomInfection(msg.sender);
        }
    }
    
    function spawnParent() external payable {
        require(msg.value >= getSpawnCost(), "Insufficient payment");
        _spawnNewParent(msg.sender);
    }
    
    function infect(uint256 parentId) external {
        _triggerInfection(parentId, msg.sender);
    }
    
    function infectRandom() external {
        _triggerRandomInfection(msg.sender);
    }
    
    function _spawnNewParent(address to) internal {
        ++_currentTokenId;
        uint256 tokenId = _currentTokenId;
        
        // Generate DNA
        uint256 dna = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            tokenId,
            to
        )));
        
        // Deploy infection contract via factory
        address infectionContract = factory.deployInfectionContract(tokenId, dna);
        
        // Store parent data
        parentData[tokenId] = ParentData({
            dna: dna,
            birthBlock: block.number,
            infectionContract: infectionContract
        });
        
        infectionContracts[tokenId] = infectionContract;
        
        // Mint the NFT
        _mint(to, tokenId);
        
        emit ParentSpawned(tokenId, to, infectionContract);
    }
    
    function _triggerInfection(uint256 parentId, address victim) internal {
        require(_exists(parentId), "Parent does not exist");
        address infectionContract = infectionContracts[parentId];
        require(infectionContract != address(0), "No infection contract");
        
        // Trigger infection
        ProtocoliteInfection(payable(infectionContract)).infect(victim);
        
        emit InfectionTriggered(parentId, victim, infectionContract);
    }
    
    function _triggerRandomInfection(address victim) internal {
        require(_currentTokenId > 0, "No parents exist");
        
        // Generate pseudo-random tokenId
        uint256 randomId = (uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            victim,
            _currentTokenId
        ))) % _currentTokenId) + 1;
        
        _triggerInfection(randomId, victim);
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        ParentData memory data = parentData[tokenId];
        
        // Create TokenData for renderer (compatible with old format)
        Protocolites.TokenData memory renderData = Protocolites.TokenData({
            dna: data.dna,
            isKid: false, // Always false for parents
            parentDna: 0, // No parent for main NFTs
            parentContract: address(0),
            birthBlock: data.birthBlock
        });
        
        return renderer.tokenURI(tokenId, renderData);
    }
    
    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }
    
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }
    
    // Allow owner to withdraw accumulated fees
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    // Get infection contract for a parent
    function getInfectionContract(uint256 parentId) external view returns (address) {
        return infectionContracts[parentId];
    }
}