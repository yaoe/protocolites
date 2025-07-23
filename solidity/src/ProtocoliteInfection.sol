// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/LibString.sol";
import "./ProtocolitesRender.sol";
import "./Protocolites.sol";

contract ProtocoliteInfection is ERC721, Ownable {
    
    uint256 public immutable parentTokenId;
    uint256 public immutable parentDna;
    uint256 private _currentTokenId;
    
    ProtocolitesRender public renderer;
    
    // Track kid NFT data
    struct KidData {
        uint256 dna;
        uint256 birthBlock;
        address infectedBy; // Who caused this infection
    }
    
    mapping(uint256 => KidData) public kidData;
    
    event Infection(uint256 indexed kidId, address indexed victim, address indexed infector);
    
    constructor(uint256 _parentTokenId, uint256 _parentDna, address _renderer) {
        parentTokenId = _parentTokenId;
        parentDna = _parentDna;
        renderer = ProtocolitesRender(_renderer);
        _initializeOwner(msg.sender); // Master contract owns this
    }
    
    function name() public view override returns (string memory) {
        return string.concat("Protocolite #", LibString.toString(parentTokenId), " Infections");
    }
    
    function symbol() public pure override returns (string memory) {
        return "INFECTION";
    }
    
    // Receive function: anyone sending ETH gets infected!
    receive() external payable {
        // Refund any ETH sent (we don't want payment)
        if (msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        }
        _infectVictim(msg.sender);
    }
    
    // Fallback: also infects
    fallback() external payable {
        if (msg.value > 0) {
            payable(msg.sender).transfer(msg.value);
        }
        _infectVictim(msg.sender);
    }
    
    // Called by master contract to infect someone
    function infect(address victim) external onlyOwner {
        _infectVictim(victim);
    }
    
    // Anyone can call this to get infected
    function getInfected() external {
        _infectVictim(msg.sender);
    }
    
    function _infectVictim(address victim) internal {
        _currentTokenId++;
        uint256 kidId = _currentTokenId;
        
        // Generate kid DNA based on parent DNA + victim + randomness
        uint256 kidDna = uint256(keccak256(abi.encodePacked(
            parentDna,
            victim,
            block.timestamp,
            block.prevrandao,
            kidId
        )));
        
        // Store kid data
        kidData[kidId] = KidData({
            dna: kidDna,
            birthBlock: block.number,
            infectedBy: victim
        });
        
        // Mint soulbound NFT
        _mint(victim, kidId);
        
        emit Infection(kidId, victim, victim);
    }
    
    // Override transfer functions to make NFTs soulbound
    function transferFrom(address, address, uint256) public payable override {
        revert("Soulbound: Transfer not allowed");
    }
    
    function safeTransferFrom(address, address, uint256) public payable override {
        revert("Soulbound: Transfer not allowed");
    }
    
    function safeTransferFrom(address, address, uint256, bytes calldata) public payable override {
        revert("Soulbound: Transfer not allowed");
    }
    
    function approve(address, uint256) public payable override {
        revert("Soulbound: Approval not allowed");
    }
    
    function setApprovalForAll(address, bool) public override {
        revert("Soulbound: Approval not allowed");
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        KidData memory data = kidData[tokenId];
        
        // Create TokenData for renderer
        Protocolites.TokenData memory renderData = Protocolites.TokenData({
            dna: data.dna,
            isKid: true, // Always true for infections  
            parentDna: parentDna,
            parentContract: address(this),
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
    
    // Get parent info
    function getParentInfo() external view returns (uint256, uint256) {
        return (parentTokenId, parentDna);
    }
    
    // Get how many times someone has been infected by this parent
    function infectionCount(address victim) external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= _currentTokenId; i++) {
            if (_exists(i) && ownerOf(i) == victim) {
                count++;
            }
        }
        return count;
    }
}