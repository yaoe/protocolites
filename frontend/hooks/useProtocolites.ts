"use client";

import { useQuery } from "@tanstack/react-query";
import { useReadContract, usePublicClient } from "wagmi";
import { MASTER_ADDRESS, MASTER_ABI, INFECTION_ABI } from "@/lib/contracts";
import { SpreaderNFT, InfectionNFT, NFTMetadata } from "@/lib/types";
import { Address, zeroAddress } from "viem";

function decodeTokenURI(uri: string): NFTMetadata | null {
  try {
    const base64 = uri.split(",")[1];
    const json = atob(base64);
    return JSON.parse(json);
  } catch (error) {
    console.error("Error decoding tokenURI:", error);
    return null;
  }
}

function extractDNA(metadata: NFTMetadata | null): string {
  if (metadata?.attributes) {
    const dnaAttr = metadata.attributes.find(
      (attr) => attr.trait_type === "DNA",
    );
    if (dnaAttr) {
      return String(dnaAttr.value);
    }
  }
  return "N/A";
}

export function useTotalSupply() {
  return useReadContract({
    address: MASTER_ADDRESS,
    abi: MASTER_ABI,
    functionName: "totalSupply",
    query: {
      refetchInterval: 30000, // Refetch every 30 seconds
    },
  });
}

/**
 * Batch array processing - process items in chunks to avoid overwhelming the RPC
 */
async function processBatch<T, R>(
  items: T[],
  batchSize: number,
  processor: (item: T) => Promise<R>,
): Promise<R[]> {
  const results: R[] = [];

  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const batchResults = await Promise.all(batch.map(processor));
    results.push(...batchResults);
  }

  return results;
}

export function useProtocolites() {
  const publicClient = usePublicClient();
  const { data: totalSupply } = useTotalSupply();

  return useQuery({
    queryKey: ["protocolites", totalSupply?.toString()],
    queryFn: async (): Promise<SpreaderNFT[]> => {
      if (!publicClient || !totalSupply) return [];

      const supply = Number(totalSupply);
      const tokenIds = Array.from({ length: supply }, (_, i) => i + 1);

      // Batch size: process 10 spreaders at a time to avoid overwhelming RPC
      const BATCH_SIZE = 10;

      const loadSpreader = async (
        tokenId: number,
      ): Promise<SpreaderNFT | null> => {
        try {
          // Fetch all spreader data in parallel
          const [tokenURI, owner, infectionAddress] = await Promise.all([
            publicClient.readContract({
              address: MASTER_ADDRESS,
              abi: MASTER_ABI,
              functionName: "tokenURI",
              args: [BigInt(tokenId)],
            }) as Promise<string>,
            publicClient.readContract({
              address: MASTER_ADDRESS,
              abi: MASTER_ABI,
              functionName: "ownerOf",
              args: [BigInt(tokenId)],
            }) as Promise<Address>,
            publicClient.readContract({
              address: MASTER_ADDRESS,
              abi: MASTER_ABI,
              functionName: "getInfectionContract",
              args: [BigInt(tokenId)],
            }) as Promise<Address>,
          ]);

          const metadata = decodeTokenURI(tokenURI);
          if (!metadata) return null;

          const dna = extractDNA(metadata);
          let infections: InfectionNFT[] = [];

          // Load infections if contract exists
          if (infectionAddress !== zeroAddress) {
            infections = await loadInfections(publicClient, infectionAddress);
          }

          return {
            tokenId,
            metadata,
            dna,
            owner,
            infectionAddress,
            infections,
          };
        } catch (error) {
          console.error(`Error loading spreader ${tokenId}:`, error);
          return null;
        }
      };

      // Process spreaders in batches
      const results = await processBatch(tokenIds, BATCH_SIZE, loadSpreader);

      // Filter out null results
      return results.filter((nft): nft is SpreaderNFT => nft !== null);
    },
    enabled: !!publicClient && !!totalSupply && totalSupply > BigInt(0),
    staleTime: 30000, // Consider data stale after 30 seconds
    refetchInterval: 60000, // Refetch every minute
  });
}

/**
 * Load all infections for a given infection contract
 */
async function loadInfections(
  publicClient: any,
  infectionAddress: Address,
): Promise<InfectionNFT[]> {
  try {
    const infectionSupply = (await publicClient.readContract({
      address: infectionAddress,
      abi: INFECTION_ABI,
      functionName: "totalSupply",
    })) as bigint;

    const infectionCount = Number(infectionSupply);
    if (infectionCount === 0) return [];

    const infectionIds = Array.from(
      { length: infectionCount },
      (_, i) => i + 1,
    );

    // Batch size for infections: process 20 at a time (they're smaller)
    const INFECTION_BATCH_SIZE = 20;

    const loadInfection = async (
      tokenId: number,
    ): Promise<InfectionNFT | null> => {
      try {
        const [infTokenURI, infOwner] = await Promise.all([
          publicClient.readContract({
            address: infectionAddress,
            abi: INFECTION_ABI,
            functionName: "tokenURI",
            args: [BigInt(tokenId)],
          }) as Promise<string>,
          publicClient.readContract({
            address: infectionAddress,
            abi: INFECTION_ABI,
            functionName: "ownerOf",
            args: [BigInt(tokenId)],
          }) as Promise<Address>,
        ]);

        const infMetadata = decodeTokenURI(infTokenURI);
        if (!infMetadata) return null;

        return {
          tokenId,
          metadata: infMetadata,
          owner: infOwner,
        };
      } catch (error) {
        console.error(`Error loading infection ${tokenId}:`, error);
        return null;
      }
    };

    const results = await processBatch(
      infectionIds,
      INFECTION_BATCH_SIZE,
      loadInfection,
    );
    return results.filter((inf): inf is InfectionNFT => inf !== null);
  } catch (error) {
    console.error("Error loading infections:", error);
    return [];
  }
}
