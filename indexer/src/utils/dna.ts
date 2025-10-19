/**
 * DNA trait parsing utilities
 * Based on DNAParser.sol library
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
 */

export interface DecodedTraits {
  bodyType: number;
  bodyChar: number;
  eyeChar: number;
  eyeSize: number;
  antennaTip: number;
  armStyle: number;
  legStyle: number;
  hatType: number;
  hasCigarette: boolean;
}

// Bit shift constants
const BODY_TYPE_SHIFT = 0n;
const BODY_CHAR_SHIFT = 3n;
const EYE_CHAR_SHIFT = 5n;
const EYE_SIZE_SHIFT = 7n;
const ANTENNA_TIP_SHIFT = 8n;
const ARM_STYLE_SHIFT = 11n;
const LEG_STYLE_SHIFT = 12n;
const HAT_TYPE_SHIFT = 13n;
const CIGARETTE_SHIFT = 16n;

// Masks to extract values
const BODY_TYPE_MASK = 0x7n; // 3 bits
const BODY_CHAR_MASK = 0x3n; // 2 bits
const EYE_CHAR_MASK = 0x3n; // 2 bits
const EYE_SIZE_MASK = 0x1n; // 1 bit
const ANTENNA_TIP_MASK = 0x7n; // 3 bits
const ARM_STYLE_MASK = 0x1n; // 1 bit
const LEG_STYLE_MASK = 0x1n; // 1 bit
const HAT_TYPE_MASK = 0x7n; // 3 bits
const CIGARETTE_MASK = 0x1n; // 1 bit

/**
 * Decode DNA bigint into individual traits
 */
export function decodeDNA(dna: bigint): DecodedTraits {
  return {
    bodyType: Number((dna >> BODY_TYPE_SHIFT) & BODY_TYPE_MASK),
    bodyChar: Number((dna >> BODY_CHAR_SHIFT) & BODY_CHAR_MASK),
    eyeChar: Number((dna >> EYE_CHAR_SHIFT) & EYE_CHAR_MASK),
    eyeSize: Number((dna >> EYE_SIZE_SHIFT) & EYE_SIZE_MASK),
    antennaTip: Number((dna >> ANTENNA_TIP_SHIFT) & ANTENNA_TIP_MASK),
    armStyle: Number((dna >> ARM_STYLE_SHIFT) & ARM_STYLE_MASK),
    legStyle: Number((dna >> LEG_STYLE_SHIFT) & LEG_STYLE_MASK),
    hatType: Number((dna >> HAT_TYPE_SHIFT) & HAT_TYPE_MASK),
    hasCigarette: ((dna >> CIGARETTE_SHIFT) & CIGARETTE_MASK) === 1n,
  };
}

/**
 * Trait names for human-readable display
 */
export const TRAIT_NAMES = {
  bodyType: ["square", "round", "diamond", "mushroom", "invader", "ghost"],
  bodyChar: ["█", "▓", "▒", "░"],
  eyeChar: ["●", "◉", "◎", "○"],
  eyeSize: ["normal", "mega"],
  antennaTip: ["●", "◉", "○", "◎", "✦", "✧", "★"],
  armStyle: ["block", "line"],
  legStyle: ["block", "line"],
  hatType: ["none", "top", "bowler", "crown", "wizard"],
};

/**
 * Get human-readable trait name
 */
export function getTraitName(
  traitType: keyof typeof TRAIT_NAMES,
  value: number
): string {
  const names = TRAIT_NAMES[traitType];
  return names[value] || `unknown_${value}`;
}
