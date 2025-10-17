// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesRender} from "../src/ProtocolitesRender.sol";
import {Protocolites} from "../src/Protocolites.sol";

contract QuickTest is Test {
    ProtocolitesRender public renderer;
    
    function setUp() public {
        renderer = new ProtocolitesRender();
    }
    
    function test_GetScript() public {
        // Just check if default script compiles
        string memory script = renderer.renderScript();
        console.log("Script length:", bytes(script).length);
        
        // Log first 500 chars
        bytes memory scriptBytes = bytes(script);
        uint256 len = scriptBytes.length > 500 ? 500 : scriptBytes.length;
        bytes memory preview = new bytes(len);
        for (uint i = 0; i < len; i++) {
            preview[i] = scriptBytes[i];
        }
        console.log("Script preview:", string(preview));
    }
}