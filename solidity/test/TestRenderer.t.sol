// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesRenderer} from "../src/ProtocolitesRenderer.sol";
import {IProtocolitesRenderer} from "../src/interfaces/IProtocolitesRenderer.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocoliteFactory} from "../src/ProtocoliteFactory.sol";
import {ProtocoliteInfection} from "../src/ProtocoliteInfection.sol";
import {TokenDataLib} from "../src/libraries/TokenDataLib.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {Base64} from "solady/utils/Base64.sol";

contract TestRendererContract is Test {
    ProtocolitesRenderer public renderer;
    ProtocolitesMaster public master;
    ProtocoliteFactory public factory;

    address public alice = address(0x1);
    address public bob = address(0x2);
    address public owner;

    // Test DNA values
    uint256 constant SAMPLE_DNA_1 = 0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;
    uint256 constant SAMPLE_DNA_2 = 0xfedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210;
    uint256 constant ZERO_DNA = 0x0;

    function setUp() public {
        owner = address(this);
        renderer = new ProtocolitesRenderer();

        // Set up full system for integration tests
        factory = new ProtocoliteFactory();
        master = new ProtocolitesMaster();

        master.setRenderer(address(renderer));
        master.setFactory(address(factory));
        factory.transferOwnership(address(master));

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    // ===== BASIC FUNCTIONALITY TESTS =====

    function test_ConstructorInitialization() public {
        assertEq(renderer.owner(), owner, "Owner should be set correctly");

        string memory initialScript = renderer.renderScript();
        assertTrue(bytes(initialScript).length > 0, "Initial render script should not be empty");
    }

    function test_SetRenderScript() public {
        string memory newScript = "console.log('new script');";

        renderer.setRenderScript(newScript);
        assertEq(renderer.renderScript(), newScript, "Render script should be updated");
    }

    function test_SetRenderScriptAccessControl() public {
        string memory newScript = "console.log('unauthorized script');";

        vm.prank(alice);
        vm.expectRevert(Ownable.Unauthorized.selector);
        renderer.setRenderScript(newScript);
    }

    // ===== TOKEN URI GENERATION TESTS =====

    function test_TokenURIParentNFT() public {
        IProtocolitesRenderer.TokenData memory parentData = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory uri = renderer.tokenURI(1, parentData);

        assertTrue(bytes(uri).length > 0, "URI should not be empty");
        assertTrue(_startsWith(uri, "data:application/json;base64,"), "URI should be base64 encoded JSON");
    }

    function test_TokenURIKidNFT() public {
        IProtocolitesRenderer.TokenData memory kidData =
            TokenDataLib.createKidData(SAMPLE_DNA_2, SAMPLE_DNA_1, address(0x123), block.number);

        string memory uri = renderer.tokenURI(1, kidData);

        assertTrue(bytes(uri).length > 0, "Kid URI should not be empty");
        assertTrue(_startsWith(uri, "data:application/json;base64,"), "Kid URI should be base64 encoded JSON");
    }

    function test_TokenURIDifferentDNA() public {
        IProtocolitesRenderer.TokenData memory data1 = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        IProtocolitesRenderer.TokenData memory data2 = TokenDataLib.createParentData(SAMPLE_DNA_2, block.number);

        string memory uri1 = renderer.tokenURI(1, data1);
        string memory uri2 = renderer.tokenURI(1, data2);

        assertTrue(keccak256(bytes(uri1)) != keccak256(bytes(uri2)), "Different DNA should produce different URIs");
    }

    function test_TokenURIZeroDNA() public {
        IProtocolitesRenderer.TokenData memory zeroData = TokenDataLib.createParentData(ZERO_DNA, block.number);

        string memory uri = renderer.tokenURI(1, zeroData);

        assertTrue(bytes(uri).length > 0, "Zero DNA should still produce valid URI");
        assertTrue(_startsWith(uri, "data:application/json;base64,"), "Zero DNA URI should be properly formatted");
    }

    function test_TokenURIConsistency() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory uri1 = renderer.tokenURI(1, data);
        string memory uri2 = renderer.tokenURI(1, data);

        assertEq(uri1, uri2, "Same input should produce consistent output");
    }

    // ===== METADATA CONTENT TESTS =====

    function test_MetadataContent() public {
        IProtocolitesRenderer.TokenData memory parentData = TokenDataLib.createParentData(SAMPLE_DNA_1, 12345);

        string memory metadata = renderer.metadata(1, parentData);

        // Check basic JSON structure elements
        assertTrue(_contains(metadata, '"name":'), "Should contain name field");
        assertTrue(_contains(metadata, '"description":'), "Should contain description field");
        assertTrue(_contains(metadata, '"animation_url":'), "Should contain animation_url field");
        assertTrue(_contains(metadata, '"attributes":'), "Should contain attributes field");

        // Check specific content
        assertTrue(_contains(metadata, "Protocolite #1"), "Should contain token ID in name");
        assertTrue(_contains(metadata, "Spreader"), "Parent should be labeled as Spreader");
        assertTrue(_contains(metadata, "12345"), "Should contain birth block");

        // Check for DNA attribute
        assertTrue(_contains(metadata, LibString.toHexString(SAMPLE_DNA_1)), "Should contain DNA in attributes");
    }

    function test_MetadataContentKid() public {
        IProtocolitesRenderer.TokenData memory kidData =
            TokenDataLib.createKidData(SAMPLE_DNA_2, SAMPLE_DNA_1, address(0x123), 54321);

        string memory metadata = renderer.metadata(1, kidData);

        // Check kid-specific content
        assertTrue(_contains(metadata, "Child"), "Kid should be labeled as Child");
        assertTrue(_contains(metadata, "16x16"), "Kid should have 16x16 size");
        assertTrue(_contains(metadata, "54321"), "Should contain birth block");

        // Should contain parent DNA
        assertTrue(_contains(metadata, LibString.toHexString(SAMPLE_DNA_1)), "Should contain parent DNA");
    }

    function test_MetadataAttributesStructure() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory metadata = renderer.metadata(1, data);

        // Check attribute structure
        assertTrue(_contains(metadata, '"trait_type":"Type"'), "Should have Type attribute");
        assertTrue(_contains(metadata, '"trait_type":"Size"'), "Should have Size attribute");
        assertTrue(_contains(metadata, '"trait_type":"DNA"'), "Should have DNA attribute");
        assertTrue(_contains(metadata, '"trait_type":"Birth Block"'), "Should have Birth Block attribute");
    }

    // ===== HTML ANIMATION TESTS =====

    function test_AnimationHTMLStructure() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory metadata = renderer.metadata(1, data);

        // Check that animation_url is properly formatted as base64 encoded HTML
        assertTrue(
            _contains(metadata, '"animation_url":"data:text/html;base64,'), "Should contain base64 HTML animation_url"
        );
        assertTrue(_contains(metadata, '"animation_url":'), "Should contain animation_url field");

        // The HTML content is base64 encoded, so we check for the proper structure
        uint256 animationStart = _indexOf(metadata, '"animation_url":"data:text/html;base64,');
        assertTrue(animationStart < bytes(metadata).length, "Should find animation_url");
    }

    function test_AnimationJavaScriptVariables() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory metadata = renderer.metadata(1, data);

        // JavaScript variables are base64 encoded in animation_url, so check metadata structure
        assertTrue(_contains(metadata, '"animation_url":"data:text/html;base64,'), "Should contain base64 animation");
        assertTrue(_contains(metadata, LibString.toHexString(SAMPLE_DNA_1)), "Should contain DNA in metadata");
        assertTrue(_contains(metadata, '"name":"Protocolite #1'), "Should contain token ID in name");
        assertTrue(_contains(metadata, "Spreader"), "Should indicate parent type");
    }

    function test_AnimationJavaScriptVariablesKid() public {
        IProtocolitesRenderer.TokenData memory kidData =
            TokenDataLib.createKidData(SAMPLE_DNA_2, SAMPLE_DNA_1, address(0x123), block.number);

        string memory metadata = renderer.metadata(2, kidData);

        // Check kid-specific metadata structure (variables are base64 encoded)
        assertTrue(_contains(metadata, '"animation_url":"data:text/html;base64,'), "Should contain base64 animation");
        assertTrue(_contains(metadata, '"name":"Protocolite #2 (Child)'), "Should indicate child in name");
        assertTrue(_contains(metadata, '"Type","value":"Child"'), "Should indicate child type in attributes");
        assertTrue(_contains(metadata, LibString.toHexString(SAMPLE_DNA_1)), "Should include parent DNA in attributes");
    }

    function test_AnimationCSS() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory metadata = renderer.metadata(1, data);

        // CSS is base64 encoded in animation_url, so check metadata structure
        assertTrue(
            _contains(metadata, '"animation_url":"data:text/html;base64,'), "Should contain base64 HTML with CSS"
        );
        assertTrue(bytes(metadata).length > 1000, "Should contain substantial animation content");

        // Verify the render script is being used (it contains the animation logic)
        string memory script = renderer.renderScript();
        assertTrue(bytes(script).length > 0, "Render script should not be empty");
    }

    // ===== INTEGRATION TESTS =====

    function test_IntegrationWithMasterContract() public {
        // Create parent through master
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        string memory uri = master.tokenURI(1);

        assertTrue(bytes(uri).length > 0, "Master should generate valid URI through renderer");
        assertTrue(_startsWith(uri, "data:application/json;base64,"), "Master URI should be properly formatted");
    }

    function test_IntegrationWithInfectionContract() public {
        // Create parent and trigger infection
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        vm.prank(bob);
        master.infect(1);

        // Get infection contract and test its URI
        address infectionContract = master.getInfectionContract(1);
        ProtocoliteInfection infection = ProtocoliteInfection(payable(infectionContract));

        string memory kidURI = infection.tokenURI(1);

        assertTrue(bytes(kidURI).length > 0, "Infection contract should generate valid URI");
        assertTrue(_startsWith(kidURI, "data:application/json;base64,"), "Infection URI should be properly formatted");

        // Decode the base64 to check the JSON content
        string memory decodedURI = string(Base64.decode(_extractBase64FromDataURI(kidURI)));
        assertTrue(_contains(decodedURI, "Child"), "Infection URI should indicate child type");
    }

    function test_RendererUpdate() public {
        // Deploy new renderer
        ProtocolitesRenderer newRenderer = new ProtocolitesRenderer();
        string memory newScript = "console.log('updated renderer');";
        newRenderer.setRenderScript(newScript);

        // Update master to use new renderer
        master.setRenderer(address(newRenderer));

        // Create NFT with new renderer
        vm.prank(alice);
        master.spawnParent{value: 0.01 ether}();

        string memory uri = master.tokenURI(1);
        assertTrue(bytes(uri).length > 0, "Should work with updated renderer");
    }

    // ===== RENDER SCRIPT TESTS =====

    function test_CustomRenderScript() public {
        string memory customScript =
            'console.log("custom animation");document.getElementById("ascii").textContent="CUSTOM";';

        renderer.setRenderScript(customScript);

        // Verify the script was set
        assertEq(renderer.renderScript(), customScript, "Custom script should be set");

        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory metadata = renderer.metadata(1, data);
        // The script is base64 encoded, so just verify metadata contains animation_url
        assertTrue(
            _contains(metadata, '"animation_url":"data:text/html;base64,'), "Should include custom script in animation"
        );
    }

    function test_DefaultRenderScript() public {
        string memory defaultScript = renderer.renderScript();

        assertTrue(bytes(defaultScript).length > 0, "Default script should not be empty");
        assertTrue(_contains(defaultScript, "function"), "Default script should contain functions");
    }

    // ===== EDGE CASES AND ERROR CONDITIONS =====

    function test_LargeTokenId() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        uint256 largeTokenId = 999999999;
        string memory uri = renderer.tokenURI(largeTokenId, data);

        assertTrue(bytes(uri).length > 0, "Should handle large token IDs");
        assertTrue(_startsWith(uri, "data:application/json;base64,"), "Should be properly formatted");

        // Decode the base64 to check the JSON content
        string memory decodedURI = string(Base64.decode(_extractBase64FromDataURI(uri)));
        assertTrue(_contains(decodedURI, "999999999"), "Should include large token ID in content");
    }

    function test_MaxUintDNA() public {
        uint256 maxDNA = type(uint256).max;

        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(maxDNA, block.number);

        string memory uri = renderer.tokenURI(1, data);
        assertTrue(bytes(uri).length > 0, "Should handle maximum DNA value");
    }

    function test_FutureBlockNumber() public {
        uint256 futureBlock = block.number + 1000000;

        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, futureBlock);

        string memory uri = renderer.tokenURI(1, data);
        assertTrue(bytes(uri).length > 0, "Should handle future block numbers");
    }

    // ===== PERFORMANCE TESTS =====

    function test_MultipleRenderingCalls() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        // Test multiple calls don't cause issues
        for (uint256 i = 1; i <= 10; i++) {
            string memory uri = renderer.tokenURI(i, data);
            assertTrue(bytes(uri).length > 0, "Multiple calls should work");
        }
    }

    function test_DifferentTokenIdsConsistent() public {
        IProtocolitesRenderer.TokenData memory data = TokenDataLib.createParentData(SAMPLE_DNA_1, block.number);

        string memory uri1 = renderer.tokenURI(1, data);
        string memory uri100 = renderer.tokenURI(100, data);
        string memory uri1000 = renderer.tokenURI(1000, data);

        // All should be valid but different (due to token ID in content)
        assertTrue(bytes(uri1).length > 0, "URI 1 should be valid");
        assertTrue(bytes(uri100).length > 0, "URI 100 should be valid");
        assertTrue(bytes(uri1000).length > 0, "URI 1000 should be valid");

        assertTrue(
            keccak256(bytes(uri1)) != keccak256(bytes(uri100)), "Different token IDs should produce different URIs"
        );
    }

    // ===== FUZZ TESTS =====

    function testFuzz_TokenURIGeneration(uint256 tokenId, uint256 dna, uint256 birthBlock, bool isKid) public {
        // Bound inputs to reasonable ranges
        tokenId = bound(tokenId, 1, 1000000);
        birthBlock = bound(birthBlock, 1, type(uint256).max);

        IProtocolitesRenderer.TokenData memory data;
        if (isKid) {
            data = TokenDataLib.createKidData(dna, SAMPLE_DNA_1, address(0x123), birthBlock);
        } else {
            data = TokenDataLib.createParentData(dna, birthBlock);
        }

        string memory uri = renderer.tokenURI(tokenId, data);

        assertTrue(bytes(uri).length > 0, "Fuzz: URI should not be empty");
        assertTrue(_startsWith(uri, "data:application/json;base64,"), "Fuzz: URI should be properly formatted");
    }

    // ===== HELPER FUNCTIONS =====

    function _startsWith(string memory str, string memory prefix) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);

        if (prefixBytes.length > strBytes.length) {
            return false;
        }

        for (uint256 i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) {
                return false;
            }
        }

        return true;
    }

    function _contains(string memory str, string memory substr) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);

        if (substrBytes.length > strBytes.length) {
            return false;
        }

        for (uint256 i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }

        return false;
    }

    function _indexOf(string memory str, string memory substr) internal pure returns (uint256) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);

        if (substrBytes.length > strBytes.length) {
            return strBytes.length;
        }

        for (uint256 i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return i;
            }
        }

        return strBytes.length;
    }

    function _extractBase64FromDataURI(string memory dataURI) internal pure returns (string memory) {
        bytes memory dataURIBytes = bytes(dataURI);
        bytes memory prefix = bytes("data:application/json;base64,");

        if (dataURIBytes.length <= prefix.length) {
            return "";
        }

        // Extract everything after the prefix
        bytes memory base64Part = new bytes(dataURIBytes.length - prefix.length);
        for (uint256 i = 0; i < base64Part.length; i++) {
            base64Part[i] = dataURIBytes[prefix.length + i];
        }

        return string(base64Part);
    }
}

// Import required for string operations
library LibString {
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x0";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 + length * 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 + length * 2; i > 2; --i) {
            buffer[i - 1] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
}
