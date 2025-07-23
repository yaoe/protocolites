// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";
import "./ProtocolitesRender.sol";
import "./ProtocoliteFactory.sol";

contract Protocolites is ERC721, Ownable {
    
    struct TokenData {
        uint256 dna;
        bool isKid;
        uint256 parentDna;
        address parentContract;
        uint256 birthBlock;
    }
    
    address public renderer;
    address public factory;
    uint256 public tokenCounter;
    uint256 public constant SPAWN_COST = 0.1 ether;
    
    mapping(uint256 => TokenData) public tokenData;
    mapping(uint256 => uint256[]) public childrenOf;
    
    event KidMinted(uint256 indexed parentId, uint256 indexed kidId, address recipient);
    event ProtocoliteSpawned(uint256 indexed parentId, address indexed newContract);
    
    constructor() {
        _initializeOwner(msg.sender);
    }
    
    // Allow contract to receive ETH for breeding
    receive() external payable {}
    
    function setRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
    }
    
    function setFactory(address _factory) external onlyOwner {
        factory = _factory;
    }
    
    // Mint initial parent Protocolites (24x24)
    function mint(address to) external onlyOwner returns (uint256) {
        uint256 tokenId = ++tokenCounter;
        uint256 dna = generateDNA(to, tokenId, block.number);
        
        tokenData[tokenId] = TokenData({
            dna: dna,
            isKid: false,
            parentDna: 0,
            parentContract: address(0),
            birthBlock: block.number
        });
        
        _mint(to, tokenId);
        return tokenId;
    }
    
    // Called on parent to breed a kid (12x12) or spawn new contract
    function breed(uint256 parentId) external payable {
        require(_exists(parentId), "Parent does not exist");
        require(!tokenData[parentId].isKid, "Kids cannot breed");
        
        if (msg.value == 0) {
            // Mint a kid NFT
            _mintKid(parentId);
        } else if (msg.value >= SPAWN_COST) {
            // Spawn a new Protocolite contract
            _spawnNewProtocolite(parentId);
            
            // Refund excess ETH
            if (msg.value > SPAWN_COST) {
                (bool success, ) = payable(msg.sender).call{value: msg.value - SPAWN_COST}("");
                require(success, "Refund failed");
            }
        } else {
            revert("Invalid ETH amount");
        }
    }
    
    function _mintKid(uint256 parentId) private {
        uint256 kidId = ++tokenCounter;
        uint256 parentDna = tokenData[parentId].dna;
        uint256 kidDna = generateDNA(msg.sender, kidId, block.number);
        
        tokenData[kidId] = TokenData({
            dna: kidDna,
            isKid: true,
            parentDna: parentDna,
            parentContract: address(this),
            birthBlock: block.number
        });
        
        childrenOf[parentId].push(kidId);
        _mint(msg.sender, kidId);
        
        emit KidMinted(parentId, kidId, msg.sender);
    }
    
    function _spawnNewProtocolite(uint256 parentId) private {
        require(factory != address(0), "Factory not set");
        
        address newProtocolite = ProtocoliteFactory(factory).spawnProtocolite(parentId, address(this), msg.sender);
        
        // Send the ETH to the owner (could be used for liquidity, treasury, etc.)
        (bool success, ) = payable(owner()).call{value: SPAWN_COST}("");
        require(success, "ETH transfer failed");
        
        emit ProtocoliteSpawned(parentId, newProtocolite);
    }
    
    function generateDNA(address user, uint256 tokenId, uint256 blockNum) private pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(user, tokenId, blockNum)));
    }
    
    function getChildrenOf(uint256 parentId) external view returns (uint256[] memory) {
        return childrenOf[parentId];
    }
    
    //////////////////////////////////////////////////////////
    // ERC721
    //////////////////////////////////////////////////////////
    
    function name() public pure override returns (string memory) {
        return "Protocolites";
    }
    
    function symbol() public pure override returns (string memory) {
        return "PRTCLTS";
    }
    
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return ProtocolitesRender(renderer).tokenURI(tokenId, tokenData[tokenId]);
    }
    
    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}


