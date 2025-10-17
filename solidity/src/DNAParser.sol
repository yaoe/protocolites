// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// A struct to hold the unpacked traits of a Protocolite.
// This makes the code in the main contract much cleaner.
struct TokenTraits {
    // Family is not part of the core DNA hash,
    // as it's derived from it. We handle it separately.
    uint8 bodyType;       // 6 types -> needs 3 bits
    uint8 bodyChar;       // 4 types -> needs 2 bits
    uint8 eyeChar;        // 4 types -> needs 2 bits
    uint8 eyeSize;        // 2 types -> needs 1 bit (0=normal, 1=mega)
    uint8 antennaTip;     // 7 types -> needs 3 bits
    uint8 armStyle;       // 2 types -> needs 1 bit (0=block, 1=line)
    uint8 legStyle;       // 2 types -> needs 1 bit (0=block, 1=line)
    uint8 hatType;        // 5 types -> needs 3 bits (0=none, 1=top, etc.)
    bool hasCigarette;    // 2 types -> needs 1 bit
}

/**
 * @title DNAParser
 * @author Your Name
 * @notice A library for encoding and decoding Protocolite traits into a uint256 DNA hash.
 * This is the core of the on-chain generative and inheritance logic.
 *
 * DNA Layout (from right to left, low bits to high bits):
 * - Bits 0-2:   bodyType (3 bits, 0-5)
 * - Bits 3-4:   bodyChar (2 bits, 0-3)
 * - Bits 5-6:   eyeChar (2 bits, 0-3)
 * - Bit 7:      eyeSize (1 bit, 0-1)
 * - Bits 8-10:  antennaTip (3 bits, 0-6)
 * - Bit 11:     armStyle (1 bit, 0-1)
 * - Bit 12:     legStyle (1 bit, 0-1)
 * - Bits 13-15: hatType (3 bits, 0-4)
 * - Bit 16:     hasCigarette (1 bit, 0-1)
 * Total bits used: 17. The rest of the 256 bits can be used for future traits or randomness.
 */
library DNAParser {
    // Bit shift constants for clarity
    uint256 private constant BODY_TYPE_SHIFT = 0;
    uint256 private constant BODY_CHAR_SHIFT = 3;
    uint256 private constant EYE_CHAR_SHIFT = 5;
    uint256 private constant EYE_SIZE_SHIFT = 7;
    uint256 private constant ANTENNA_TIP_SHIFT = 8;
    uint256 private constant ARM_STYLE_SHIFT = 11;
    uint256 private constant LEG_STYLE_SHIFT = 12;
    uint256 private constant HAT_TYPE_SHIFT = 13;
    uint256 private constant CIGARETTE_SHIFT = 16;

    // Masks to extract values
    uint256 private constant BODY_TYPE_MASK = 0x7;    // 3 bits (111)
    uint256 private constant BODY_CHAR_MASK = 0x3;    // 2 bits (11)
    uint256 private constant EYE_CHAR_MASK = 0x3;     // 2 bits (11)
    uint256 private constant EYE_SIZE_MASK = 0x1;     // 1 bit (1)
    uint256 private constant ANTENNA_TIP_MASK = 0x7;  // 3 bits (111)
    uint256 private constant ARM_STYLE_MASK = 0x1;    // 1 bit (1)
    uint256 private constant LEG_STYLE_MASK = 0x1;    // 1 bit (1)
    uint256 private constant HAT_TYPE_MASK = 0x7;     // 3 bits (111)
    uint256 private constant CIGARETTE_MASK = 0x1;    // 1 bit (1)

    /// @notice Decodes a DNA hash into a struct of its traits.
    function decode(uint256 dna) internal pure returns (TokenTraits memory traits) {
        traits.bodyType = uint8((dna >> BODY_TYPE_SHIFT) & BODY_TYPE_MASK);
        traits.bodyChar = uint8((dna >> BODY_CHAR_SHIFT) & BODY_CHAR_MASK);
        traits.eyeChar = uint8((dna >> EYE_CHAR_SHIFT) & EYE_CHAR_MASK);
        traits.eyeSize = uint8((dna >> EYE_SIZE_SHIFT) & EYE_SIZE_MASK);
        traits.antennaTip = uint8((dna >> ANTENNA_TIP_SHIFT) & ANTENNA_TIP_MASK);
        traits.armStyle = uint8((dna >> ARM_STYLE_SHIFT) & ARM_STYLE_MASK);
        traits.legStyle = uint8((dna >> LEG_STYLE_SHIFT) & LEG_STYLE_MASK);
        traits.hatType = uint8((dna >> HAT_TYPE_SHIFT) & HAT_TYPE_MASK);
        traits.hasCigarette = ((dna >> CIGARETTE_SHIFT) & CIGARETTE_MASK) == 1;
        return traits;
    }

    /// @notice Encodes a struct of traits into a single DNA hash.
    /// @param traits The traits to encode
    /// @param parentDna Optional parent DNA to preserve family (pass 0 if no parent)
    function encode(TokenTraits memory traits, uint256 parentDna) internal pure returns (uint256 dna) {
        // Use a local variable to accumulate the bitwise operations.
        uint256 result = 0;

        result |= (uint256(traits.bodyType) & BODY_TYPE_MASK) << BODY_TYPE_SHIFT;
        result |= (uint256(traits.bodyChar) & BODY_CHAR_MASK) << BODY_CHAR_SHIFT;
        result |= (uint256(traits.eyeChar) & EYE_CHAR_MASK) << EYE_CHAR_SHIFT;
        result |= (uint256(traits.eyeSize) & EYE_SIZE_MASK) << EYE_SIZE_SHIFT;
        result |= (uint256(traits.antennaTip) & ANTENNA_TIP_MASK) << ANTENNA_TIP_SHIFT;
        result |= (uint256(traits.armStyle) & ARM_STYLE_MASK) << ARM_STYLE_SHIFT;
        result |= (uint256(traits.legStyle) & LEG_STYLE_MASK) << LEG_STYLE_SHIFT;
        result |= (uint256(traits.hatType) & HAT_TYPE_MASK) << HAT_TYPE_SHIFT;

        if (traits.hasCigarette) {
            result |= (1 << CIGARETTE_SHIFT);
        }

        // If we have a parent, use parent's high bits to preserve family color
        // The renderer hashes the full DNA to determine family, so we need full-length DNA
        if (parentDna != 0) {
            // Keep our traits in low 17 bits, copy parent's high bits (for family consistency)
            // This makes kids hash to same family as parents in the JavaScript renderer
            uint256 parentHighBits = parentDna & ~uint256(0x1FFFF); // Mask out low 17 bits
            result |= parentHighBits;
        } else {
            // No parent - hash the traits to create full 256-bit DNA
            result = uint256(keccak256(abi.encode(result)));
        }

        dna = result;
    }
}