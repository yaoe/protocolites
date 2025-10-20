// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ProtocolitesRendererUltra} from "../src/ProtocolitesRendererUltra.sol";
import {IProtocolitesRenderer} from "../src/interfaces/IProtocolitesRenderer.sol";

contract TestOptimizedRenderer is Test {
    ProtocolitesRendererUltra renderer;

    function setUp() public {
        renderer = new ProtocolitesRendererUltra();
    }

    function testGasUsageAdult() public {
        IProtocolitesRenderer.TokenData memory data = IProtocolitesRenderer.TokenData({
            dna: 0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234,
            isKid: false,
            parentDna: 0,
            parentContract: address(0x1234),
            birthBlock: 19000000
        });

        uint256 gasBefore = gasleft();
        string memory uri = renderer.tokenURI(1, data);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("\n=== ADULT PROTOCOLITE GAS USAGE ===");
        console.log("Gas used:", gasUsed);
        console.log("Under 1M limit:", gasUsed < 1_000_000 ? "YES" : "NO");
        console.log("Output size:", bytes(uri).length, "bytes");
        console.log("");

        // Decode and show metadata size
        string memory metadata = renderer.metadata(1, data);
        console.log("Metadata size:", bytes(metadata).length, "bytes");
        console.log("");

        assertTrue(gasUsed < 1_000_000, "Gas usage exceeds 1M limit");
    }

    function testGasUsageKid() public {
        IProtocolitesRenderer.TokenData memory data = IProtocolitesRenderer.TokenData({
            dna: 0xfedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210,
            isKid: true,
            parentDna: 0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234,
            parentContract: address(0x5678),
            birthBlock: 19500000
        });

        uint256 gasBefore = gasleft();
        string memory uri = renderer.tokenURI(42, data);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("\n=== KID PROTOCOLITE GAS USAGE ===");
        console.log("Gas used:", gasUsed);
        console.log("Under 1M limit:", gasUsed < 1_000_000 ? "YES" : "NO");
        console.log("Output size:", bytes(uri).length, "bytes");
        console.log("");

        // Decode and show metadata size
        string memory metadata = renderer.metadata(42, data);
        console.log("Metadata size:", bytes(metadata).length, "bytes");
        console.log("");

        assertTrue(gasUsed < 1_000_000, "Gas usage exceeds 1M limit");
    }

    function testMultipleDNAVariants() public {
        console.log("\n=== TESTING MULTIPLE DNA VARIANTS ===");

        uint256[5] memory testDNAs = [
            uint256(0x1111111111111111111111111111111111111111111111111111111111111111),
            uint256(0x5555555555555555555555555555555555555555555555555555555555555555),
            uint256(0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa),
            uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff),
            uint256(0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0)
        ];

        uint256 maxGas = 0;
        uint256 minGas = type(uint256).max;
        uint256 totalGas = 0;

        for (uint256 i = 0; i < testDNAs.length; i++) {
            IProtocolitesRenderer.TokenData memory data = IProtocolitesRenderer.TokenData({
                dna: testDNAs[i],
                isKid: false,
                parentDna: 0,
                parentContract: address(uint160(i + 1)),
                birthBlock: 19000000 + i
            });

            uint256 gasBefore = gasleft();
            renderer.tokenURI(i + 1, data);
            uint256 gasUsed = gasBefore - gasleft();

            if (gasUsed > maxGas) maxGas = gasUsed;
            if (gasUsed < minGas) minGas = gasUsed;
            totalGas += gasUsed;

            console.log("DNA variant", i + 1, "gas:", gasUsed);
        }

        uint256 avgGas = totalGas / testDNAs.length;
        console.log("");
        console.log("Min gas:", minGas);
        console.log("Max gas:", maxGas);
        console.log("Avg gas:", avgGas);
        console.log("");
        console.log("All under 1M:", maxGas < 1_000_000 ? "YES" : "NO");

        assertTrue(maxGas < 1_000_000, "Some variants exceed 1M gas limit");
    }

    function testOutputFormat() public view {
        IProtocolitesRenderer.TokenData memory data = IProtocolitesRenderer.TokenData({
            dna: 0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234,
            isKid: false,
            parentDna: 0,
            parentContract: address(0x1234),
            birthBlock: 19000000
        });

        string memory uri = renderer.tokenURI(1, data);

        console.log("\n=== OUTPUT PREVIEW ===");
        console.log("First 200 chars of tokenURI:");
        console.log(substring(uri, 0, 200));
        console.log("");
    }

    // Helper function to get substring
    function substring(string memory str, uint256 startIndex, uint256 length) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        if (startIndex >= strBytes.length) return "";
        if (startIndex + length > strBytes.length) length = strBytes.length - startIndex;

        bytes memory result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = strBytes[startIndex + i];
        }
        return string(result);
    }
}
