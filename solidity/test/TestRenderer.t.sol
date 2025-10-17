// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {Protocolites} from "../src/Protocolites.sol";

contract TestRendererOutput is Test {
    ProtocolitesRender public renderer;
    
    function setUp() public {
        renderer = new ProtocolitesRender();
    }
    
    function test_RenderParent() public {
        // Create parent data
        Protocolites.TokenData memory data = Protocolites.TokenData({
            dna: uint256(keccak256("test")),
            isKid: false,
            parentDna: 0,
            parentContract: address(0),
            birthBlock: 1
        });
        
        string memory uri = renderer.tokenURI(1, data);
        console.log("Parent URI length:", bytes(uri).length);
        console.log(uri);
    }
    
    function test_RenderKid() public {
        // Create kid data
        Protocolites.TokenData memory data = Protocolites.TokenData({
            dna: uint256(keccak256("kid")),
            isKid: true,
            parentDna: uint256(keccak256("parent")),
            parentContract: address(this),
            birthBlock: 1
        });
        
        string memory uri = renderer.tokenURI(2, data);
        console.log("Kid URI length:", bytes(uri).length);
        console.log(uri);
    }
}