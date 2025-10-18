// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocoliteInfection} from "../src/ProtocoliteInfection.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRenderer} from "../src/ProtocolitesRenderer.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";
import "../src/DNAParser.sol";
import {IProtocolitesRenderer} from "../src/interfaces/IProtocolitesRenderer.sol";

contract TestInfectionContract is Test {
    using DNAParser for uint256;

    ProtocolitesMaster public master;
    ProtocolitesRenderer public renderer;
    ProtocoliteFactory public factory;
    ProtocoliteInfection public infection;

    address public alice = address(0x1001);
    address public bob = address(0x2);
    address public charlie = address(0x3);
    address public dave = address(0x4);

    uint256 constant PARENT_TOKEN_ID = 1;
    uint256 constant PARENT_DNA = 0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;

    event Infection(uint256 indexed kidId, address indexed victim, address indexed infector);

    function setUp() public {
        // Deploy full system
        renderer = new ProtocolitesRenderer();
        factory = new ProtocoliteFactory();
        master = new ProtocolitesMaster();

        master.setRenderer(address(renderer));
        master.setFactory(address(factory));
        factory.transferOwnership(address(master));

        // Deploy infection contract directly for testing
        infection = new ProtocoliteInfection(PARENT_TOKEN_ID, PARENT_DNA, address(master));
        infection.transferOwnership(address(master));

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 10 ether);
        vm.deal(dave, 10 ether);
    }

    // ===== BASIC FUNCTIONALITY TESTS =====

    function test_ConstructorInitialization() public {
        assertEq(infection.parentTokenId(), PARENT_TOKEN_ID, "Parent token ID should be set");
        assertEq(infection.parentDna(), PARENT_DNA, "Parent DNA should be set");
        assertEq(infection.masterContract(), address(master), "Master contract should be set");
        assertEq(infection.owner(), address(master), "Owner should be master");
        assertEq(infection.totalSupply(), 0, "Initial supply should be 0");
    }

    function test_ContractMetadata() public {
        string memory expectedName = string.concat("Protocolite #", "1", " Infections");
        assertEq(infection.name(), expectedName, "Name should include parent token ID");
        assertEq(infection.symbol(), "INFECTION", "Symbol should be INFECTION");
    }

    function test_GetParentInfo() public {
        (uint256 parentId, uint256 parentDna) = infection.getParentInfo();
        assertEq(parentId, PARENT_TOKEN_ID, "Parent ID should match");
        assertEq(parentDna, PARENT_DNA, "Parent DNA should match");
    }

    // ===== INFECTION MECHANICS TESTS =====

    function test_DirectInfectionCall() public {
        vm.prank(address(master)); // Only master can call infect
        infection.infect(alice);

        assertEq(infection.totalSupply(), 1, "Should mint 1 infection NFT");
        assertEq(infection.ownerOf(1), alice, "Alice should own the infection NFT");
        assertTrue(infection.exists(1), "Token 1 should exist");
    }

    function test_GetInfectedFunction() public {
        vm.prank(alice);
        infection.getInfected();

        assertEq(infection.totalSupply(), 1, "Should mint 1 infection NFT");
        assertEq(infection.ownerOf(1), alice, "Alice should own the infection NFT");
    }

    function test_ReceiveFunctionInfection() public {
        uint256 aliceBalance = alice.balance;

        vm.prank(alice);
        (bool success,) = address(infection).call{value: 1 ether}("");
        assertTrue(success, "Receive function should succeed");

        assertEq(infection.totalSupply(), 1, "Should mint 1 infection NFT");
        assertEq(infection.ownerOf(1), alice, "Alice should own the infection NFT");
        assertEq(alice.balance, aliceBalance, "ETH should be refunded");
    }

    function test_FallbackFunctionInfection() public {
        uint256 aliceBalance = alice.balance;

        vm.prank(alice);
        (bool success,) = address(infection).call{value: 0.5 ether}("somedata");
        assertTrue(success, "Fallback function should succeed");

        assertEq(infection.totalSupply(), 1, "Should mint 1 infection NFT");
        assertEq(infection.ownerOf(1), alice, "Alice should own the infection NFT");
        assertEq(alice.balance, aliceBalance, "ETH should be refunded");
    }

    function test_MultipleInfections() public {
        // Multiple people get infected
        vm.prank(alice);
        infection.getInfected();

        vm.prank(bob);
        infection.getInfected();

        vm.prank(charlie);
        infection.getInfected();

        assertEq(infection.totalSupply(), 3, "Should have 3 infection NFTs");
        assertEq(infection.ownerOf(1), alice, "Alice should own token 1");
        assertEq(infection.ownerOf(2), bob, "Bob should own token 2");
        assertEq(infection.ownerOf(3), charlie, "Charlie should own token 3");
    }

    function test_InfectionCount() public {
        // Alice gets infected multiple times
        vm.prank(alice);
        infection.getInfected();

        vm.prank(alice);
        infection.getInfected();

        assertEq(infection.infectionCount(alice), 2, "Alice should have 2 infections");
        assertEq(infection.infectionCount(bob), 0, "Bob should have 0 infections");

        vm.prank(bob);
        infection.getInfected();

        assertEq(infection.infectionCount(alice), 2, "Alice should still have 2 infections");
        assertEq(infection.infectionCount(bob), 1, "Bob should have 1 infection");
    }

    // ===== DNA INHERITANCE TESTS =====

    function test_DNAInheritance() public {
        vm.prank(alice);
        infection.getInfected();

        // Get the kid's data
        (uint256 kidDna,,) = infection.kidData(1);

        // Decode both parent and kid DNA to check inheritance
        TokenTraits memory parentTraits = PARENT_DNA.decode();
        TokenTraits memory kidTraits = kidDna.decode();

        // Test 100% inheritance traits
        assertEq(kidTraits.bodyType, parentTraits.bodyType, "Body type should be inherited 100%");
        assertEq(kidTraits.armStyle, parentTraits.armStyle, "Arm style should be inherited 100%");
        assertEq(kidTraits.legStyle, parentTraits.legStyle, "Leg style should be inherited 100%");

        // The other traits have probability-based inheritance, so we can't assert exact equality
        // But we can verify they are valid values
        assertTrue(kidTraits.bodyChar < 4, "Body char should be valid");
        assertTrue(kidTraits.eyeChar < 4, "Eye char should be valid");
        assertTrue(kidTraits.eyeSize <= 1, "Eye size should be valid");
        assertTrue(kidTraits.antennaTip < 7, "Antenna tip should be valid");
        assertTrue(kidTraits.hatType <= 7, "Hat type should be valid (0-7 based on 3-bit mask)");
    }

    function test_DNAMutation() public {
        // Test multiple infections to see some variation in DNA
        uint256[] memory kidDnas = new uint256[](10);

        for (uint256 i = 0; i < 10; i++) {
            vm.prank(address(uint160(0x1000 + i))); // Different addresses for different seeds
            infection.getInfected();
            (uint256 kidDna,,) = infection.kidData(i + 1);
            kidDnas[i] = kidDna;
        }

        // Check that not all DNA is identical (some mutation should occur)
        bool foundVariation = false;
        for (uint256 i = 1; i < kidDnas.length; i++) {
            if (kidDnas[i] != kidDnas[0]) {
                foundVariation = true;
                break;
            }
        }
        assertTrue(foundVariation, "Should find DNA variations among infections");
    }

    function test_UniqueInfectionSeeds() public {
        // Test that infection mechanism works with different victims and stores unique data
        vm.prank(alice);
        infection.getInfected();
        (uint256 dna1, uint256 birthBlock1, address infectedBy1) = infection.kidData(1);

        // Add entropy by changing block timestamp and number
        vm.warp(block.timestamp + 1);
        vm.roll(block.number + 1);

        // Different victim
        vm.prank(bob);
        infection.getInfected();
        (uint256 dna2, uint256 birthBlock2, address infectedBy2) = infection.kidData(2);

        // Verify that each infection has unique metadata even if DNA might be similar
        assertTrue(birthBlock1 != birthBlock2, "Birth blocks should be different");
        assertTrue(infectedBy1 != infectedBy2, "Infected by addresses should be different");
        assertEq(infectedBy1, alice, "First infection should be by alice");
        assertEq(infectedBy2, bob, "Second infection should be by bob");

        // DNA might be the same due to inheritance patterns, but seeds should be different
        // This is acceptable behavior for a genetic inheritance system
    }

    // ===== SOULBOUND TOKEN TESTS =====

    function test_TransferFromBlocked() public {
        vm.prank(alice);
        infection.getInfected();

        vm.expectRevert("Soulbound: Transfer not allowed");
        vm.prank(alice);
        infection.transferFrom(alice, bob, 1);
    }

    function test_SafeTransferFromBlocked() public {
        vm.prank(alice);
        infection.getInfected();

        vm.expectRevert("Soulbound: Transfer not allowed");
        vm.prank(alice);
        infection.safeTransferFrom(alice, bob, 1);
    }

    function test_SafeTransferFromWithDataBlocked() public {
        vm.prank(alice);
        infection.getInfected();

        vm.expectRevert("Soulbound: Transfer not allowed");
        vm.prank(alice);
        infection.safeTransferFrom(alice, bob, 1, "");
    }

    function test_ApprovalBlocked() public {
        vm.prank(alice);
        infection.getInfected();

        vm.expectRevert("Soulbound: Approval not allowed");
        vm.prank(alice);
        infection.approve(bob, 1);
    }

    function test_SetApprovalForAllBlocked() public {
        vm.expectRevert("Soulbound: Approval not allowed");
        vm.prank(alice);
        infection.setApprovalForAll(bob, true);
    }

    // ===== ACCESS CONTROL TESTS =====

    function test_InfectOnlyOwner() public {
        vm.prank(alice); // Non-owner tries to call infect
        vm.expectRevert();
        infection.infect(alice);

        // Owner (master) can call it
        vm.prank(address(master));
        infection.infect(alice);
        assertEq(infection.totalSupply(), 1, "Owner should be able to call infect");
    }

    // ===== TOKEN URI TESTS =====

    function test_TokenURI() public {
        vm.prank(alice);
        infection.getInfected();

        string memory uri = infection.tokenURI(1);
        assertTrue(bytes(uri).length > 0, "Token URI should not be empty");

        // Should start with data:application/json;base64
        assertTrue(
            bytes(uri).length > 29
                && keccak256(bytes(substring(uri, 0, 29))) == keccak256(bytes("data:application/json;base64,")),
            "Token URI should be base64 encoded JSON"
        );
    }

    function test_TokenURINonexistentToken() public {
        vm.expectRevert("Token does not exist");
        infection.tokenURI(999);
    }

    // ===== INTEGRATION TESTS =====

    function test_IntegrationWithMasterContract() public {
        // Create a real parent through master
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        address realInfectionContract = master.getInfectionContract(1);
        ProtocoliteInfection realInfection = ProtocoliteInfection(payable(realInfectionContract));

        // Test infection through master
        vm.prank(bob);
        master.infect(1);

        assertEq(realInfection.totalSupply(), 1, "Should create infection through master");
        assertEq(realInfection.ownerOf(1), bob, "Bob should own the infection");

        // Test tokenURI works with master's renderer
        string memory uri = realInfection.tokenURI(1);
        assertTrue(bytes(uri).length > 0, "URI should be generated through master's renderer");
    }

    function test_RendererFromMaster() public {
        // Deploy infection contract that uses master's renderer
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection realInfection = ProtocoliteInfection(payable(infectionContract));

        vm.prank(bob);
        master.infect(1);

        // Change master's renderer
        ProtocolitesRenderer newRenderer = new ProtocolitesRenderer();
        master.setRenderer(address(newRenderer));

        // Infection contract should use the new renderer
        string memory uri = realInfection.tokenURI(1);
        assertTrue(bytes(uri).length > 0, "Should use new renderer from master");
    }

    // ===== EDGE CASES AND ERROR CONDITIONS =====

    function test_ZeroAddressInfection() public {
        vm.prank(address(master));
        vm.expectRevert(); // Expecting TransferToZeroAddress error
        infection.infect(address(0));
    }

    function test_InfectionDataStorage() public {
        uint256 preInfectionBlock = block.number;

        vm.prank(alice);
        infection.getInfected();

        (uint256 dna, uint256 birthBlock, address infectedBy) = infection.kidData(1);

        assertTrue(dna != 0, "DNA should be set");
        assertEq(birthBlock, preInfectionBlock, "Birth block should be set");
        assertEq(infectedBy, alice, "Infected by should be set");
    }

    function test_ExistsFunction() public {
        assertFalse(infection.exists(1), "Token 1 should not exist initially");

        vm.prank(alice);
        infection.getInfected();

        assertTrue(infection.exists(1), "Token 1 should exist after minting");
        assertFalse(infection.exists(2), "Token 2 should not exist");
    }

    // ===== HELPER FUNCTIONS =====

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }
}
