// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Protocolites} from "../src/Protocolites.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";

contract ViewNFTTest is Test {
    Protocolites public protocolites;
    ProtocolitesRender public renderer;
    ProtocoliteFactory public factory;
    
    address public alice = address(0x1);
    
    function setUp() public {
        renderer = new ProtocolitesRender();
        factory = new ProtocoliteFactory();
        protocolites = new Protocolites();
        
        protocolites.setRenderer(address(renderer));
        protocolites.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        factory.registerProtocolite(address(protocolites));
        
        vm.deal(alice, 10 ether);
    }
    
    function test_ViewParentNFT() public {
        // Mint a parent
        uint256 parentId = protocolites.mint(alice);
        
        // Get the tokenURI
        string memory uri = protocolites.tokenURI(parentId);
        
        console.log("=== PARENT NFT #1 ===");
        console.log("TokenURI:");
        console.log(uri);
        console.log("");
        
        // Get token data
        (uint256 dna, bool isKid, uint256 parentDna, address parentContract, uint256 birthBlock) = protocolites.tokenData(parentId);
        console.log("DNA:", vm.toString(dna));
        console.log("Is Kid:", isKid);
        console.log("Birth Block:", birthBlock);
    }
    
    function test_ViewKidNFT() public {
        // Mint a parent
        uint256 parentId = protocolites.mint(alice);
        
        // Breed a kid
        vm.prank(alice);
        protocolites.breed(parentId);
        
        uint256 kidId = 2;
        string memory kidUri = protocolites.tokenURI(kidId);
        
        console.log("=== KID NFT #2 ===");
        console.log("TokenURI:");
        console.log(kidUri);
        console.log("");
        
        // Get token data
        (uint256 kidDna, bool isKid, uint256 parentDna, address parentContract, uint256 birthBlock) = protocolites.tokenData(kidId);
        console.log("Kid DNA:", vm.toString(kidDna));
        console.log("Parent DNA:", vm.toString(parentDna));
        console.log("Is Kid:", isKid);
    }
    
    function test_ViewMultipleNFTs() public {
        console.log("=== GENERATING MULTIPLE PROTOCOLITES ===");
        
        uint256 nextTokenId = 1;
        
        // Create 3 parents and their kids
        for (uint i = 0; i < 3; i++) {
            // Mint parent
            uint256 parentId = protocolites.mint(alice);
            string memory uri = protocolites.tokenURI(parentId);
            
            console.log("Parent #", parentId);
            console.log(uri);
            console.log("---");
            
            nextTokenId++; // Next token will be the kid
            
            // Create a kid from this parent
            vm.prank(alice);
            protocolites.breed(parentId);
            
            uint256 kidId = nextTokenId;
            string memory kidUri = protocolites.tokenURI(kidId);
            
            console.log("Kid #", kidId);
            console.log(kidUri);
            console.log("=================");
            
            nextTokenId++; // Increment for next parent
        }
    }
}