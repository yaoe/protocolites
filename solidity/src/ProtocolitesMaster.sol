// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/LibString.sol";
import "solady/utils/ReentrancyGuard.sol";
import "./ProtocoliteInfection.sol";
import "./ProtocoliteFactory.sol";
import "./interfaces/IProtocolitesRenderer.sol";
import "./libraries/TokenDataLib.sol";

/**
 * @title ProtocolitesMaster
 * @author Protocolites Team
 * @notice Main NFT contract implementing viral inheritance mechanics where NFTs can "infect" others
 * @dev Spawns parent NFTs when receiving sufficient ETH, triggers infections otherwise
 *      Uses reentrancy protection on all payable functions for security
 */
contract ProtocolitesMaster is ERC721, Ownable, ReentrancyGuard {
    uint256 private _currentTokenId;

    ProtocoliteFactory public factory;
    IProtocolitesRenderer public renderer;

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
    event RendererUpdated(address indexed oldRenderer, address indexed newRenderer);
    event FactoryUpdated(address indexed oldFactory, address indexed newFactory);

    /**
     * @notice Initializes the ProtocolitesMaster contract
     * @dev Sets the deployer as the initial owner
     */
    constructor() {
        _initializeOwner(msg.sender);
    }

    /**
     * @notice Returns the name of the NFT collection
     * @return The collection name "Protocolites"
     */
    function name() public pure override returns (string memory) {
        return "Protocolites";
    }

    /**
     * @notice Returns the symbol of the NFT collection
     * @return The collection symbol "PROTO"
     */
    function symbol() public pure override returns (string memory) {
        return "PROTO";
    }

    /**
     * @notice Updates the factory contract used to deploy infection contracts
     * @dev Only owner can call this function. Validates that factory is a valid contract
     * @param _factory Address of the new ProtocoliteFactory contract
     * @custom:emits FactoryUpdated
     */
    function setFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "Invalid factory address");
        require(_factory.code.length > 0, "Factory must be a contract");
        address oldFactory = address(factory);
        factory = ProtocoliteFactory(_factory);
        emit FactoryUpdated(oldFactory, _factory);
    }

    /**
     * @notice Updates the renderer contract used to generate NFT metadata
     * @dev Only owner can call this function. Validates that renderer is a valid contract
     * @param _renderer Address of the new renderer contract implementing IProtocolitesRenderer
     * @custom:emits RendererUpdated
     */
    function setRenderer(address _renderer) external onlyOwner {
        require(_renderer != address(0), "Invalid renderer address");
        require(_renderer.code.length > 0, "Renderer must be a contract");
        address oldRenderer = address(renderer);
        renderer = IProtocolitesRenderer(_renderer);
        emit RendererUpdated(oldRenderer, _renderer);
    }

    /**
     * @notice Returns the cost to spawn a new parent NFT based on current network
     * @dev Dynamic pricing: 0.001 ETH on Sepolia testnet, 0.01 ETH on other networks
     * @return The spawn cost in wei
     */
    function getSpawnCost() public view returns (uint256) {
        // Sepolia testnet
        if (block.chainid == 11155111) {
            return 0.001 ether;
        }
        // Mainnet and all other networks
        return 0.01 ether;
    }

    /**
     * @notice Handles direct ETH transfers to the contract
     * @dev Spawns new parent if sufficient ETH sent, otherwise triggers random infection
     *      Protected against reentrancy attacks
     * @custom:emits ParentSpawned if spawning parent
     * @custom:emits InfectionTriggered if triggering infection
     */
    receive() external payable nonReentrant {
        if (msg.value >= getSpawnCost()) {
            _spawnNewParent(msg.sender);
        } else {
            // Trigger random infection
            _triggerRandomInfection(msg.sender);
        }
    }

    /**
     * @notice Handles function calls with calldata, primarily for targeted infections
     * @dev Attempts to decode tokenId from calldata for targeted infection,
     *      falls back to random infection if no tokenId provided
     *      Protected against reentrancy attacks
     * @custom:emits InfectionTriggered
     */
    fallback() external payable nonReentrant {
        require(msg.value == 0, "Use receive() for paid spawns");

        // Try to decode tokenId from calldata
        if (msg.data.length >= 32) {
            uint256 tokenId = abi.decode(msg.data, (uint256));
            _triggerInfection(tokenId, msg.sender);
        } else {
            _triggerRandomInfection(msg.sender);
        }
    }

    /**
     * @notice Explicitly spawns a new parent NFT by paying the required cost
     * @dev Must send at least getSpawnCost() ETH. Protected against reentrancy
     * @custom:emits ParentSpawned
     */
    function spawnParent() external payable nonReentrant {
        require(msg.value >= getSpawnCost(), "Insufficient payment");
        _spawnNewParent(msg.sender);
    }

    /**
     * @notice Triggers infection from a specific parent NFT
     * @dev Creates a child NFT in the parent's infection contract
     * @param parentId The token ID of the parent NFT to infect from
     * @custom:emits InfectionTriggered
     */
    function infect(uint256 parentId) external {
        _triggerInfection(parentId, msg.sender);
    }

    /**
     * @notice Triggers infection from a randomly selected parent NFT
     * @dev Creates a child NFT from a pseudo-random existing parent
     * @custom:emits InfectionTriggered
     */
    function infectRandom() external {
        _triggerRandomInfection(msg.sender);
    }

    function _spawnNewParent(address to) internal {
        ++_currentTokenId;
        uint256 tokenId = _currentTokenId;

        // Generate DNA
        uint256 dna = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, tokenId, to)));

        // Deploy infection contract via factory
        address infectionContract = factory.deployInfectionContract(tokenId, dna);

        // Store parent data
        parentData[tokenId] = ParentData({dna: dna, birthBlock: block.number, infectionContract: infectionContract});

        infectionContracts[tokenId] = infectionContract;

        // Mint the NFT
        _mint(to, tokenId);

        emit ParentSpawned(tokenId, to, infectionContract);
    }

    function _triggerInfection(uint256 parentId, address victim) internal {
        require(_exists(parentId), "Parent does not exist");
        address infectionContract = infectionContracts[parentId];
        require(infectionContract != address(0), "No infection contract");

        // Check external call success
        try ProtocoliteInfection(payable(infectionContract)).infect(victim) {
            emit InfectionTriggered(parentId, victim, infectionContract);
        } catch Error(string memory reason) {
            revert(string.concat("Infection failed: ", reason));
        } catch {
            revert("Infection failed: unknown error");
        }
    }

    function _triggerRandomInfection(address victim) internal {
        require(_currentTokenId > 0, "No parents exist");

        // Generate pseudo-random tokenId
        uint256 randomId = (
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, victim, _currentTokenId)))
                % _currentTokenId
        ) + 1;

        _triggerInfection(randomId, victim);
    }

    /**
     * @notice Returns the metadata URI for a given token ID
     * @dev Generates on-chain metadata through the renderer contract
     * @param tokenId The token ID to get metadata for
     * @return Base64-encoded JSON metadata URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        ParentData memory data = parentData[tokenId];

        // Create TokenData for renderer using library
        IProtocolitesRenderer.TokenData memory renderData = TokenDataLib.createParentData(data.dna, data.birthBlock);

        return renderer.tokenURI(tokenId, renderData);
    }

    /**
     * @notice Returns the total number of parent NFTs minted
     * @return The current token supply count
     */
    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }

    /**
     * @notice Checks if a token ID exists
     * @param tokenId The token ID to check
     * @return True if the token exists, false otherwise
     */
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    /**
     * @notice Allows owner to withdraw accumulated ETH fees
     * @dev Only the contract owner can call this function
     */
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
     * @notice Returns the infection contract address for a given parent token
     * @param parentId The parent token ID
     * @return The address of the associated infection contract
     */
    function getInfectionContract(uint256 parentId) external view returns (address) {
        return infectionContracts[parentId];
    }
}
