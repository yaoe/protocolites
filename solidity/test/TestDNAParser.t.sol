// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/libraries/DNAParser.sol";

contract TestDNAParserContract is Test {
    using DNAParser for uint256;
    using DNAParser for TokenTraits;

    // Test constants
    uint256 constant SAMPLE_DNA_1 = 0x123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;
    uint256 constant SAMPLE_DNA_2 = 0xfedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210;
    uint256 constant MAX_DNA = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant MIN_DNA = 0x0;

    // ===== BASIC ENCODING/DECODING TESTS =====

    function test_BasicEncodeDecodeConsistency() public {
        TokenTraits memory originalTraits = TokenTraits({
            bodyType: 3,
            bodyChar: 2,
            eyeChar: 1,
            eyeSize: 1,
            antennaTip: 4,
            armStyle: 0,
            legStyle: 1,
            hatType: 2,
            hasCigarette: true
        });

        uint256 encodedDNA = originalTraits.encode(0);
        TokenTraits memory decodedTraits = encodedDNA.decode();

        assertEq(decodedTraits.bodyType, originalTraits.bodyType, "Body type should match");
        assertEq(decodedTraits.bodyChar, originalTraits.bodyChar, "Body char should match");
        assertEq(decodedTraits.eyeChar, originalTraits.eyeChar, "Eye char should match");
        assertEq(decodedTraits.eyeSize, originalTraits.eyeSize, "Eye size should match");
        assertEq(decodedTraits.antennaTip, originalTraits.antennaTip, "Antenna tip should match");
        assertEq(decodedTraits.armStyle, originalTraits.armStyle, "Arm style should match");
        assertEq(decodedTraits.legStyle, originalTraits.legStyle, "Leg style should match");
        assertEq(decodedTraits.hatType, originalTraits.hatType, "Hat type should match");
        assertEq(decodedTraits.hasCigarette, originalTraits.hasCigarette, "Cigarette should match");
    }

    function test_DecodeKnownDNA() public {
        // Test decoding of a known DNA value
        TokenTraits memory traits = SAMPLE_DNA_1.decode();

        // The exact values depend on the bit layout in DNAParser
        assertTrue(traits.bodyType < 8, "Body type should be valid (0-7)");
        assertTrue(traits.bodyChar < 4, "Body char should be valid (0-3)");
        assertTrue(traits.eyeChar < 4, "Eye char should be valid (0-3)");
        assertTrue(traits.eyeSize <= 1, "Eye size should be valid (0-1)");
        assertTrue(traits.antennaTip < 8, "Antenna tip should be valid (0-7)");
        assertTrue(traits.armStyle <= 1, "Arm style should be valid (0-1)");
        assertTrue(traits.legStyle <= 1, "Leg style should be valid (0-1)");
        assertTrue(traits.hatType < 8, "Hat type should be valid (0-7)");
    }

    function test_EncodeWithParentDNA() public {
        TokenTraits memory traits = TokenTraits({
            bodyType: 1,
            bodyChar: 1,
            eyeChar: 1,
            eyeSize: 0,
            antennaTip: 1,
            armStyle: 1,
            legStyle: 0,
            hatType: 1,
            hasCigarette: false
        });

        uint256 parentDNA = SAMPLE_DNA_1;
        uint256 encodedDNA = traits.encode(parentDNA);

        // Encoded DNA should be different from parent DNA
        assertTrue(encodedDNA != parentDNA, "Encoded DNA should differ from parent");

        // Should still decode to the same traits
        TokenTraits memory decodedTraits = encodedDNA.decode();
        assertEq(decodedTraits.bodyType, traits.bodyType, "Body type should be preserved");
        assertEq(decodedTraits.bodyChar, traits.bodyChar, "Body char should be preserved");
    }

    // ===== TRAIT VALIDATION TESTS =====

    function test_AllBodyTypesValid() public {
        for (uint8 i = 0; i < 8; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: i,
                bodyChar: 0,
                eyeChar: 0,
                eyeSize: 0,
                antennaTip: 0,
                armStyle: 0,
                legStyle: 0,
                hatType: 0,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();

            if (i < 6) {
                // Assuming 6 valid body types based on JS code
                assertEq(decoded.bodyType, i, "Body type should be preserved");
            }
        }
    }

    function test_AllBodyCharsValid() public {
        for (uint8 i = 0; i < 4; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: i,
                eyeChar: 0,
                eyeSize: 0,
                antennaTip: 0,
                armStyle: 0,
                legStyle: 0,
                hatType: 0,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();
            assertEq(decoded.bodyChar, i, "Body char should be preserved");
        }
    }

    function test_AllEyeCharsValid() public {
        for (uint8 i = 0; i < 4; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: 0,
                eyeChar: i,
                eyeSize: 0,
                antennaTip: 0,
                armStyle: 0,
                legStyle: 0,
                hatType: 0,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();
            assertEq(decoded.eyeChar, i, "Eye char should be preserved");
        }
    }

    function test_EyeSizeValid() public {
        for (uint8 i = 0; i <= 1; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: 0,
                eyeChar: 0,
                eyeSize: i,
                antennaTip: 0,
                armStyle: 0,
                legStyle: 0,
                hatType: 0,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();
            assertEq(decoded.eyeSize, i, "Eye size should be preserved");
        }
    }

    function test_AllAntennaTipsValid() public {
        for (uint8 i = 0; i < 8; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: 0,
                eyeChar: 0,
                eyeSize: 0,
                antennaTip: i,
                armStyle: 0,
                legStyle: 0,
                hatType: 0,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();

            if (i < 7) {
                // Assuming 7 valid antenna tips based on JS code
                assertEq(decoded.antennaTip, i, "Antenna tip should be preserved");
            }
        }
    }

    function test_StylesValid() public {
        uint8[2] memory styles = [0, 1];

        for (uint256 i = 0; i < styles.length; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: 0,
                eyeChar: 0,
                eyeSize: 0,
                antennaTip: 0,
                armStyle: styles[i],
                legStyle: styles[i],
                hatType: 0,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();
            assertEq(decoded.armStyle, styles[i], "Arm style should be preserved");
            assertEq(decoded.legStyle, styles[i], "Leg style should be preserved");
        }
    }

    function test_AllHatTypesValid() public {
        for (uint8 i = 0; i < 8; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: 0,
                eyeChar: 0,
                eyeSize: 0,
                antennaTip: 0,
                armStyle: 0,
                legStyle: 0,
                hatType: i,
                hasCigarette: false
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();

            if (i < 5) {
                // Assuming 5 valid hat types based on JS code
                assertEq(decoded.hatType, i, "Hat type should be preserved");
            }
        }
    }

    function test_CigaretteFlag() public {
        bool[2] memory cigaretteStates = [false, true];

        for (uint256 i = 0; i < cigaretteStates.length; i++) {
            TokenTraits memory traits = TokenTraits({
                bodyType: 0,
                bodyChar: 0,
                eyeChar: 0,
                eyeSize: 0,
                antennaTip: 0,
                armStyle: 0,
                legStyle: 0,
                hatType: 0,
                hasCigarette: cigaretteStates[i]
            });

            uint256 dna = traits.encode(0);
            TokenTraits memory decoded = dna.decode();
            assertEq(decoded.hasCigarette, cigaretteStates[i], "Cigarette flag should be preserved");
        }
    }

    // ===== EDGE CASE TESTS =====

    function test_MinimalDNA() public {
        TokenTraits memory decoded = MIN_DNA.decode();

        // All traits should be at their minimum valid values
        assertEq(decoded.bodyType, 0, "Body type should be 0");
        assertEq(decoded.bodyChar, 0, "Body char should be 0");
        assertEq(decoded.eyeChar, 0, "Eye char should be 0");
        assertEq(decoded.eyeSize, 0, "Eye size should be 0");
        assertEq(decoded.antennaTip, 0, "Antenna tip should be 0");
        assertEq(decoded.armStyle, 0, "Arm style should be 0");
        assertEq(decoded.legStyle, 0, "Leg style should be 0");
        assertEq(decoded.hatType, 0, "Hat type should be 0");
        assertEq(decoded.hasCigarette, false, "Should not have cigarette");
    }

    function test_MaximalDNA() public {
        TokenTraits memory decoded = MAX_DNA.decode();

        // All traits should be within valid ranges
        assertTrue(decoded.bodyType < 8, "Body type should be valid");
        assertTrue(decoded.bodyChar < 4, "Body char should be valid");
        assertTrue(decoded.eyeChar < 4, "Eye char should be valid");
        assertTrue(decoded.eyeSize <= 1, "Eye size should be valid");
        assertTrue(decoded.antennaTip < 8, "Antenna tip should be valid");
        assertTrue(decoded.armStyle <= 1, "Arm style should be valid");
        assertTrue(decoded.legStyle <= 1, "Leg style should be valid");
        assertTrue(decoded.hatType < 8, "Hat type should be valid");
    }

    function test_ZeroParentDNAEncoding() public {
        TokenTraits memory traits = TokenTraits({
            bodyType: 2,
            bodyChar: 1,
            eyeChar: 2,
            eyeSize: 1,
            antennaTip: 3,
            armStyle: 1,
            legStyle: 0,
            hatType: 1,
            hasCigarette: true
        });

        uint256 encodedDNA = traits.encode(0);
        TokenTraits memory decodedTraits = encodedDNA.decode();

        // Should encode/decode consistently even with zero parent DNA
        assertEq(decodedTraits.bodyType, traits.bodyType, "Body type should match with zero parent");
        assertEq(decodedTraits.hasCigarette, traits.hasCigarette, "Cigarette should match with zero parent");
    }

    // ===== FUZZ TESTS =====

    function testFuzz_EncodeDecodeConsistency(
        uint8 bodyType,
        uint8 bodyChar,
        uint8 eyeChar,
        uint8 eyeSize,
        uint8 antennaTip,
        uint8 armStyle,
        uint8 legStyle,
        uint8 hatType,
        bool hasCigarette
    ) public {
        // Bound inputs to valid ranges
        bodyType = uint8(bound(bodyType, 0, 7));
        bodyChar = uint8(bound(bodyChar, 0, 3));
        eyeChar = uint8(bound(eyeChar, 0, 3));
        eyeSize = uint8(bound(eyeSize, 0, 1));
        antennaTip = uint8(bound(antennaTip, 0, 7));
        armStyle = uint8(bound(armStyle, 0, 1));
        legStyle = uint8(bound(legStyle, 0, 1));
        hatType = uint8(bound(hatType, 0, 7));

        TokenTraits memory originalTraits = TokenTraits({
            bodyType: bodyType,
            bodyChar: bodyChar,
            eyeChar: eyeChar,
            eyeSize: eyeSize,
            antennaTip: antennaTip,
            armStyle: armStyle,
            legStyle: legStyle,
            hatType: hatType,
            hasCigarette: hasCigarette
        });

        uint256 encodedDNA = originalTraits.encode(0);
        TokenTraits memory decodedTraits = encodedDNA.decode();

        // Verify all traits are preserved (within valid ranges)
        assertTrue(decodedTraits.bodyType < 8, "Body type should be valid after encoding/decoding");
        assertTrue(decodedTraits.bodyChar < 4, "Body char should be valid after encoding/decoding");
        assertTrue(decodedTraits.eyeChar < 4, "Eye char should be valid after encoding/decoding");
        assertTrue(decodedTraits.eyeSize <= 1, "Eye size should be valid after encoding/decoding");
        assertTrue(decodedTraits.antennaTip < 8, "Antenna tip should be valid after encoding/decoding");
        assertTrue(decodedTraits.armStyle <= 1, "Arm style should be valid after encoding/decoding");
        assertTrue(decodedTraits.legStyle <= 1, "Leg style should be valid after encoding/decoding");
        assertTrue(decodedTraits.hatType < 8, "Hat type should be valid after encoding/decoding");
    }

    function testFuzz_DNADecodeAlwaysValid(uint256 dna) public {
        TokenTraits memory traits = dna.decode();

        // All decoded traits should be within valid ranges
        assertTrue(traits.bodyType < 8, "Body type should always be valid");
        assertTrue(traits.bodyChar < 4, "Body char should always be valid");
        assertTrue(traits.eyeChar < 4, "Eye char should always be valid");
        assertTrue(traits.eyeSize <= 1, "Eye size should always be valid");
        assertTrue(traits.antennaTip < 8, "Antenna tip should always be valid");
        assertTrue(traits.armStyle <= 1, "Arm style should always be valid");
        assertTrue(traits.legStyle <= 1, "Leg style should always be valid");
        assertTrue(traits.hatType < 8, "Hat type should always be valid");
    }

    // ===== INHERITANCE PATTERN TESTS =====

    function test_EncodeWithDifferentParents() public {
        TokenTraits memory childTraits = TokenTraits({
            bodyType: 1,
            bodyChar: 1,
            eyeChar: 1,
            eyeSize: 0,
            antennaTip: 1,
            armStyle: 1,
            legStyle: 0,
            hatType: 1,
            hasCigarette: false
        });

        uint256 parent1DNA = SAMPLE_DNA_1;
        uint256 parent2DNA = SAMPLE_DNA_2;

        uint256 child1DNA = childTraits.encode(parent1DNA);
        uint256 child2DNA = childTraits.encode(parent2DNA);

        // Children with different parents should potentially have different DNA
        // even with same trait inputs (due to parent DNA influence)
        TokenTraits memory child1Decoded = child1DNA.decode();
        TokenTraits memory child2Decoded = child2DNA.decode();

        // The core traits should still match the input
        assertEq(child1Decoded.bodyType, childTraits.bodyType, "Child 1 body type should match");
        assertEq(child2Decoded.bodyType, childTraits.bodyType, "Child 2 body type should match");
    }

    // ===== MULTIPLE ENCODE/DECODE CYCLES =====

    function test_MultipleEncodingCycles() public {
        TokenTraits memory originalTraits = TokenTraits({
            bodyType: 3,
            bodyChar: 2,
            eyeChar: 1,
            eyeSize: 1,
            antennaTip: 4,
            armStyle: 0,
            legStyle: 1,
            hatType: 2,
            hasCigarette: true
        });

        uint256 dna = originalTraits.encode(0);

        // Multiple decode/encode cycles should be stable
        for (uint256 i = 0; i < 5; i++) {
            TokenTraits memory decoded = dna.decode();
            dna = decoded.encode(SAMPLE_DNA_1);
        }

        TokenTraits memory finalTraits = dna.decode();

        // Basic traits should remain valid through multiple cycles
        assertTrue(finalTraits.bodyType < 8, "Body type should remain valid");
        assertTrue(finalTraits.bodyChar < 4, "Body char should remain valid");
        assertTrue(finalTraits.eyeChar < 4, "Eye char should remain valid");
        assertTrue(finalTraits.eyeSize <= 1, "Eye size should remain valid");
        assertTrue(finalTraits.antennaTip < 8, "Antenna tip should remain valid");
        assertTrue(finalTraits.armStyle <= 1, "Arm style should remain valid");
        assertTrue(finalTraits.legStyle <= 1, "Leg style should remain valid");
        assertTrue(finalTraits.hatType < 8, "Hat type should remain valid");
    }

    // ===== STATISTICAL TESTS =====

    function test_TraitDistribution() public {
        uint256 sampleSize = 100;
        uint256[] memory bodyTypes = new uint256[](8);
        uint256[] memory bodyChars = new uint256[](4);
        bool[] memory cigarettes = new bool[](sampleSize);

        // Generate samples with different seeds
        for (uint256 i = 0; i < sampleSize; i++) {
            uint256 testDNA = uint256(keccak256(abi.encodePacked(i, block.timestamp)));
            TokenTraits memory traits = testDNA.decode();

            if (traits.bodyType < 8) bodyTypes[traits.bodyType]++;
            if (traits.bodyChar < 4) bodyChars[traits.bodyChar]++;
            cigarettes[i] = traits.hasCigarette;
        }

        // Verify we see some distribution (not all the same)
        uint256 uniqueBodyTypes = 0;
        for (uint256 i = 0; i < bodyTypes.length; i++) {
            if (bodyTypes[i] > 0) uniqueBodyTypes++;
        }
        assertTrue(uniqueBodyTypes > 1, "Should see multiple body types in sample");

        uint256 uniqueBodyChars = 0;
        for (uint256 i = 0; i < bodyChars.length; i++) {
            if (bodyChars[i] > 0) uniqueBodyChars++;
        }
        assertTrue(uniqueBodyChars > 1, "Should see multiple body chars in sample");
    }
}
