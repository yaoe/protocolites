// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Protocolites} from "../src/Protocolites.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";

contract ProtocolitesTest is Test {
    Protocolites public protocolites;
    ProtocolitesRender public renderer;
    ProtocoliteFactory public factory;
    
    address public alice = address(0x1);
    address public bob = address(0x2);
    
    // Allow test contract to receive ETH
    receive() external payable {}
    
    function setUp() public {
        // Deploy contracts
        renderer = new ProtocolitesRender();
        factory = new ProtocoliteFactory();
        protocolites = new Protocolites();
        
        // Set up connections
        protocolites.setRenderer(address(renderer));
        protocolites.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        factory.registerProtocolite(address(protocolites));
        
        // Fund test accounts
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }
    
    function test_MintParent() public {
        // Owner mints a parent Protocolite
        uint256 tokenId = protocolites.mint(alice);
        assertEq(tokenId, 1);
        assertEq(protocolites.ownerOf(tokenId), alice);
        
        // Check token data
        (uint256 dna, bool isKid, uint256 parentDna, address parentContract, uint256 birthBlock) = protocolites.tokenData(tokenId);
        assertGt(dna, 0);
        assertEq(isKid, false);
        assertEq(parentDna, 0);
        assertEq(parentContract, address(0));
        assertEq(birthBlock, block.number);
    }
    
    function test_BreedKid() public {
        // Mint parent
        uint256 parentId = protocolites.mint(alice);
        
        // Alice breeds a kid
        vm.prank(alice);
        protocolites.breed(parentId);
        
        // Check kid was minted
        uint256 kidId = 2;
        assertEq(protocolites.ownerOf(kidId), alice);
        
        // Check kid data
        (uint256 kidDna, bool isKid, uint256 parentDna, address parentContract,) = protocolites.tokenData(kidId);
        assertGt(kidDna, 0);
        assertEq(isKid, true);
        (uint256 actualParentDna,,,,) = protocolites.tokenData(parentId);
        assertEq(parentDna, actualParentDna);
        assertEq(parentContract, address(protocolites));
        
        // Check children tracking
        uint256[] memory children = protocolites.getChildrenOf(parentId);
        assertEq(children.length, 1);
        assertEq(children[0], kidId);
    }
    
    function test_KidsCannotBreed() public {
        // Mint parent and breed kid
        uint256 parentId = protocolites.mint(alice);
        vm.prank(alice);
        protocolites.breed(parentId);
        
        uint256 kidId = 2;
        
        // Try to breed from kid - should fail
        vm.prank(alice);
        vm.expectRevert("Kids cannot breed");
        protocolites.breed(kidId);
    }
    
    function test_SpawnNewProtocolite() public {
        // Mint parent
        uint256 parentId = protocolites.mint(alice);
        
        // Record balance before
        uint256 balanceBefore = address(protocolites.owner()).balance;
        
        // Alice spawns new Protocolite contract
        vm.prank(alice);
        protocolites.breed{value: 0.1 ether}(parentId);
        
        // Check ETH was sent to owner
        assertEq(address(protocolites.owner()).balance, balanceBefore + 0.1 ether);
        
        // Check new contract was spawned
        address[] memory spawned = factory.getSpawnedByAddress(alice);
        assertEq(spawned.length, 1);
        
        // Verify new contract
        Protocolites newProtocolite = Protocolites(payable(spawned[0]));
        assertEq(newProtocolite.owner(), alice);
        assertEq(newProtocolite.renderer(), address(renderer));
    }
    
    function test_RefundExcessETH() public {
        uint256 parentId = protocolites.mint(alice);
        
        uint256 aliceBalanceBefore = alice.balance;
        
        // Send excess ETH
        vm.prank(alice);
        protocolites.breed{value: 0.2 ether}(parentId);
        
        // Check alice got refund
        assertEq(alice.balance, aliceBalanceBefore - 0.1 ether);
    }
    
    function test_InvalidETHAmount() public {
        uint256 parentId = protocolites.mint(alice);
        
        // Send invalid amount
        vm.prank(alice);
        vm.expectRevert("Invalid ETH amount");
        protocolites.breed{value: 0.05 ether}(parentId);
    }
    
    function test_TokenURI() public {
        // Mint parent
        uint256 parentId = protocolites.mint(alice);
        
        // Get URI
        string memory uri = protocolites.tokenURI(parentId);
        assertTrue(bytes(uri).length > 0);
        
        // Basic check that it's a data URI
        assertTrue(_startsWith(uri, "data:application/json;base64,"));
    }
    
    function test_MultipleKids() public {
        uint256 parentId = protocolites.mint(alice);
        
        // Breed multiple kids
        vm.startPrank(alice);
        protocolites.breed(parentId);
        protocolites.breed(parentId);
        protocolites.breed(parentId);
        vm.stopPrank();
        
        // Check all kids were minted
        uint256[] memory children = protocolites.getChildrenOf(parentId);
        assertEq(children.length, 3);
        assertEq(children[0], 2);
        assertEq(children[1], 3);
        assertEq(children[2], 4);
    }
    
    function test_UpdateRenderScript() public {
        string memory newScript = "console.log('new script');";
        
        renderer.setRenderScript(newScript);
        assertEq(renderer.renderScript(), newScript);
    }
    
    function test_OnlyOwnerCanUpdateScript() public {
        vm.prank(alice);
        vm.expectRevert();
        renderer.setRenderScript("malicious script");
    }
    
    function test_FactoryTracking() public {
        // Register another protocolite
        address newProtocolite = address(0x123);
        factory.registerProtocolite(newProtocolite);
        assertTrue(factory.isProtocolite(newProtocolite));
    }
    
    // Helper function
    function _startsWith(string memory str, string memory prefix) private pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);
        
        if (prefixBytes.length > strBytes.length) return false;
        
        for (uint i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) return false;
        }
        
        return true;
    }
}