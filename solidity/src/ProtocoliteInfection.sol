// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/tokens/ERC721.sol";
import "solady/auth/Ownable.sol";
import "solady/utils/LibString.sol";
import "./interfaces/IProtocolitesRenderer.sol";
import "./libraries/DNAParser.sol";
import "./libraries/TokenDataLib.sol";

interface IMaster {
    function renderer() external view returns (IProtocolitesRenderer);
}

contract ProtocoliteInfection is ERC721, Ownable {
    using DNAParser for uint256; // Attach library functions to uint256
    using DNAParser for TokenTraits; // Attach library functions to the struct

    uint256 public immutable parentTokenId;
    uint256 public immutable parentDna;
    uint256 private _currentTokenId;

    // Store master contract address instead of renderer
    // This way kids always use the same renderer as master
    address public immutable masterContract;

    // Track kid NFT data
    struct KidData {
        uint256 dna;
        uint256 birthBlock;
        address infectedBy; // Who caused this infection
    }

    mapping(uint256 => KidData) public kidData;

    event Infection(uint256 indexed kidId, address indexed victim, address indexed infector);

    constructor(uint256 _parentTokenId, uint256 _parentDna, address _masterContract) {
        parentTokenId = _parentTokenId;
        parentDna = _parentDna;
        masterContract = _masterContract;

        // Initialize ownership - factory will transfer to master after deployment
        _initializeOwner(msg.sender);

        // Kids will dynamically read renderer from masterContract
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

        // 1. DECODE PARENT'S TRAITS
        TokenTraits memory parentTraits = parentDna.decode();

        // 2. GENERATE CHILD'S RANDOMNESS SEED
        // This matches the HTML: unique seed per child
        uint256 childSeed =
            uint256(keccak256(abi.encodePacked(parentDna, victim, block.timestamp, block.prevrandao, kidId)));

        // 3. SEEDED PRNG (matches HTML's random() function exactly)
        // HTML: let s = seed; (uses FULL seed value, modulo only happens inside random())
        uint256 s = childSeed;

        // 4. CONSTRUCT CHILD'S TRAITS using advancing PRNG
        TokenTraits memory childTraits;

        // == 100% INHERITANCE ==
        childTraits.bodyType = parentTraits.bodyType;
        childTraits.armStyle = parentTraits.armStyle;
        childTraits.legStyle = parentTraits.legStyle;

        // == 80% INHERITANCE / 20% MUTATION ==

        // Body Character (80% chance to inherit)
        unchecked {
            s = (s * 9301 + 49297) % 233280;
        }
        if (s < 186624) {
            // 233280 * 0.8 = 186624
            childTraits.bodyChar = parentTraits.bodyChar;
        } else {
            unchecked {
                s = (s * 9301 + 49297) % 233280;
            }
            childTraits.bodyChar = uint8((s * 4) / 233280);
        }

        // Eye Character (80% chance)
        unchecked {
            s = (s * 9301 + 49297) % 233280;
        }
        if (s < 186624) {
            childTraits.eyeChar = parentTraits.eyeChar;
        } else {
            unchecked {
                s = (s * 9301 + 49297) % 233280;
            }
            childTraits.eyeChar = uint8((s * 4) / 233280);
        }

        // Eye Size (80% chance)
        unchecked {
            s = (s * 9301 + 49297) % 233280;
        }
        if (s < 186624) {
            childTraits.eyeSize = parentTraits.eyeSize;
        } else {
            unchecked {
                s = (s * 9301 + 49297) % 233280;
            }
            childTraits.eyeSize = s > 116640 ? 1 : 0; // >0.5 = mega
        }

        // Antenna Tip (80% chance)
        unchecked {
            s = (s * 9301 + 49297) % 233280;
        }
        if (s < 186624) {
            childTraits.antennaTip = parentTraits.antennaTip;
        } else {
            unchecked {
                s = (s * 9301 + 49297) % 233280;
            }
            childTraits.antennaTip = uint8((s * 7) / 233280);
        }

        // Hat Type (Complex logic - matches HTML lines 767-777)
        if (parentTraits.hatType != 0) {
            // Parent has hat: 80% chance to inherit
            unchecked {
                s = (s * 9301 + 49297) % 233280;
            }
            if (s < 186624) {
                childTraits.hatType = parentTraits.hatType;
            } else {
                unchecked {
                    s = (s * 9301 + 49297) % 233280;
                }
                childTraits.hatType = uint8((s * 5) / 233280);
            }
        } else {
            // Parent has no hat: 15% chance to get one
            unchecked {
                s = (s * 9301 + 49297) % 233280;
            }
            if (s < 34992) {
                // 233280 * 0.15 = 34992
                unchecked {
                    s = (s * 9301 + 49297) % 233280;
                }
                childTraits.hatType = uint8(((s * 4) / 233280) + 1); // 1-4 (not none)
            } else {
                childTraits.hatType = 0; // none
            }
        }

        // Cigarette (10% chance - matches HTML line 780)
        unchecked {
            s = (s * 9301 + 49297) % 233280;
        }
        childTraits.hasCigarette = s < 23328; // 233280 * 0.10 = 23328

        // 5. ENCODE THE NEW TRAITS
        uint256 kidDna = childTraits.encode(parentDna);

        // 5. STORE AND MINT
        // Store kid data
        kidData[kidId] = KidData({
            dna: kidDna,
            birthBlock: block.number,
            infectedBy: victim // Or however you track the parent
        });

        // Mint soulbound NFT
        _mint(victim, kidId);

        emit Infection(kidId, victim, victim); // Adjust event as needed
    }

    function _infectVictim2(address victim) internal {
        _currentTokenId++;
        uint256 kidId = _currentTokenId;

        // Generate kid DNA based on parent DNA + victim + randomness
        uint256 kidDna =
            uint256(keccak256(abi.encodePacked(parentDna, victim, block.timestamp, block.prevrandao, kidId)));

        // Store kid data
        kidData[kidId] = KidData({dna: kidDna, birthBlock: block.number, infectedBy: victim});

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

        // Create TokenData for renderer using library
        IProtocolitesRenderer.TokenData memory renderData =
            TokenDataLib.createKidData(data.dna, parentDna, address(this), data.birthBlock);

        // Get renderer from master contract (so kids always use same renderer as master)
        IProtocolitesRenderer currentRenderer = IMaster(masterContract).renderer();
        return currentRenderer.tokenURI(tokenId, renderData);
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
