import { Address } from 'viem'

export interface NFTMetadata {
  name: string
  description?: string
  image?: string
  animation_url?: string
  attributes?: Array<{
    trait_type: string
    value: string | number
  }>
}

export interface InfectionNFT {
  tokenId: number
  metadata: NFTMetadata
  owner: Address
}

export interface SpreaderNFT {
  tokenId: number
  metadata: NFTMetadata
  dna: string
  owner: Address
  infectionAddress: Address
  infections: InfectionNFT[]
}
