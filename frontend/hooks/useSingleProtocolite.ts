'use client'

import { useQuery } from '@tanstack/react-query'
import { usePublicClient } from 'wagmi'
import { MASTER_ADDRESS, MASTER_ABI, INFECTION_ABI } from '@/lib/contracts'
import { SpreaderNFT, InfectionNFT, NFTMetadata } from '@/lib/types'
import { Address, zeroAddress } from 'viem'

function decodeTokenURI(uri: string): NFTMetadata | null {
  try {
    const base64 = uri.split(',')[1]
    const json = atob(base64)
    return JSON.parse(json)
  } catch (error) {
    console.error('Error decoding tokenURI:', error)
    return null
  }
}

function extractDNA(metadata: NFTMetadata | null): string {
  if (metadata?.attributes) {
    const dnaAttr = metadata.attributes.find((attr) => attr.trait_type === 'DNA')
    if (dnaAttr) {
      return String(dnaAttr.value)
    }
  }
  return 'N/A'
}

async function loadInfections(
  publicClient: any,
  infectionAddress: Address
): Promise<InfectionNFT[]> {
  try {
    const infectionSupply = (await publicClient.readContract({
      address: infectionAddress,
      abi: INFECTION_ABI,
      functionName: 'totalSupply',
    })) as bigint

    const infectionCount = Number(infectionSupply)
    if (infectionCount === 0) return []

    const infectionPromises = []
    for (let i = 1; i <= infectionCount; i++) {
      infectionPromises.push(
        (async () => {
          try {
            const [infTokenURI, infOwner] = await Promise.all([
              publicClient.readContract({
                address: infectionAddress,
                abi: INFECTION_ABI,
                functionName: 'tokenURI',
                args: [BigInt(i)],
              }) as Promise<string>,
              publicClient.readContract({
                address: infectionAddress,
                abi: INFECTION_ABI,
                functionName: 'ownerOf',
                args: [BigInt(i)],
              }) as Promise<Address>,
            ])

            const infMetadata = decodeTokenURI(infTokenURI)
            if (!infMetadata) return null

            return {
              tokenId: i,
              metadata: infMetadata,
              owner: infOwner,
            }
          } catch (error) {
            console.error(`Error loading infection ${i}:`, error)
            return null
          }
        })()
      )
    }

    const results = await Promise.all(infectionPromises)
    return results.filter((inf): inf is InfectionNFT => inf !== null)
  } catch (error) {
    console.error('Error loading infections:', error)
    return []
  }
}

export function useSingleProtocolite(tokenId: number) {
  const publicClient = usePublicClient()

  return useQuery({
    queryKey: ['protocolite', tokenId],
    queryFn: async (): Promise<SpreaderNFT> => {
      if (!publicClient) {
        throw new Error('Public client not available')
      }

      // Fetch all spreader data in parallel
      const [tokenURI, owner, infectionAddress] = await Promise.all([
        publicClient.readContract({
          address: MASTER_ADDRESS,
          abi: MASTER_ABI,
          functionName: 'tokenURI',
          args: [BigInt(tokenId)],
        }) as Promise<string>,
        publicClient.readContract({
          address: MASTER_ADDRESS,
          abi: MASTER_ABI,
          functionName: 'ownerOf',
          args: [BigInt(tokenId)],
        }) as Promise<Address>,
        publicClient.readContract({
          address: MASTER_ADDRESS,
          abi: MASTER_ABI,
          functionName: 'getInfectionContract',
          args: [BigInt(tokenId)],
        }) as Promise<Address>,
      ])

      const metadata = decodeTokenURI(tokenURI)
      if (!metadata) {
        throw new Error('Failed to decode token metadata')
      }

      const dna = extractDNA(metadata)
      let infections: InfectionNFT[] = []

      // Load infections if contract exists
      if (infectionAddress !== zeroAddress) {
        infections = await loadInfections(publicClient, infectionAddress)
      }

      return {
        tokenId,
        metadata,
        dna,
        owner,
        infectionAddress,
        infections,
      }
    },
    enabled: !!publicClient && tokenId > 0,
    staleTime: 30000,
    refetchInterval: 60000,
  })
}
