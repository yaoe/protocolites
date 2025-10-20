/**
 * Metadata decoding utilities
 */

export interface NFTMetadata {
  name?: string;
  description?: string;
  image?: string;
  animation_url?: string;
  attributes?: Array<{
    trait_type: string;
    value: string | number;
  }>;
}

/**
 * Decode base64 data URI to JSON metadata
 */
export function decodeTokenURI(uri: string): NFTMetadata | null {
  try {
    if (!uri || !uri.startsWith("data:")) {
      return null;
    }

    // Format: data:application/json;base64,<base64data>
    const base64Data = uri.split(",")[1];
    if (!base64Data) {
      return null;
    }

    const jsonString = Buffer.from(base64Data, "base64").toString("utf-8");
    const metadata = JSON.parse(jsonString) as NFTMetadata;

    return metadata;
  } catch (error) {
    console.error("Error decoding tokenURI:", error);
    return null;
  }
}

/**
 * Extract specific attribute from metadata
 */
export function extractAttribute(
  metadata: NFTMetadata | null,
  traitType: string
): string | number | null {
  if (!metadata?.attributes) {
    return null;
  }

  const attr = metadata.attributes.find((a) => a.trait_type === traitType);
  return attr?.value ?? null;
}
