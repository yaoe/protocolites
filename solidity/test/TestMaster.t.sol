// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {ProtocoliteFactoryNew} from "../src/ProtocoliteFactoryNew.sol";

contract TestMasterContract is Test {
    ProtocolitesMaster public master;
    ProtocolitesRender public renderer;
    ProtocoliteFactoryNew public factory;
    
    address public alice = address(0x1);
    
    function setUp() public {
        renderer = new ProtocolitesRender();
        factory = new ProtocoliteFactoryNew();
        master = new ProtocolitesMaster();
        
        master.setRenderer(address(renderer));
        master.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        
        // Transfer factory ownership to master
        factory.transferOwnership(address(master));
        
        vm.deal(alice, 10 ether);
    }
    
    function test_SendETHToSpawn() public {
        // Test sending ETH directly to contract
        vm.prank(alice);
        (bool success,) = address(master).call{value: 0.01 ether}("");
        assertTrue(success, "ETH transfer failed");
        
        // Check NFT was minted
        assertEq(master.totalSupply(), 1);
        assertEq(master.ownerOf(1), alice);
    }
    
    function test_SendZeroETHForInfection() public {
        // First spawn a parent
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();
        
        // Try to send 0 ETH (should fail initially since no parents exist)
        address bob = address(0x2);
        vm.deal(bob, 1 ether);
        vm.prank(bob);
        (bool success,) = address(master).call{value: 0}("");
        assertTrue(success, "Zero ETH transfer failed");
    }
}