# Protocolites Indexer

A high-performance blockchain indexer for the Protocolites NFT protocol built with [Ponder](https://ponder.sh).

## Overview

This indexer tracks:
- **Spreaders** (Parent NFTs from ProtocolitesMaster)
- **Infections** (Child NFTs from dynamically created ProtocoliteInfection contracts)
- **DNA traits** decoded and indexed for fast filtering
- **Ownership** and transfer history
- **Statistics** across the entire protocol

## Features

- ✅ **Real-time indexing** of Sepolia testnet
- ✅ **Dynamic contract indexing** for infection contracts
- ✅ **DNA trait decoding** for searchable attributes
- ✅ **REST API** with pagination support
- ✅ **GraphQL API** for flexible queries
- ✅ **Decoded metadata** stored for fast access

## Setup

### 1. Install dependencies

```bash
pnpm install
```

### 2. Configure environment

Copy `.env.example` to `.env` and add your RPC URL:

```bash
cp .env.example .env
```

Edit `.env`:

```env
PONDER_RPC_URL_11155111=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
```

### 3. Run the indexer

Development mode (hot reload):

```bash
pnpm dev
```

Production mode:

```bash
pnpm start
```

The indexer will:
1. Start syncing from block 9440296 (deployment block)
2. Index all ParentSpawned and Infection events
3. Decode DNA traits and metadata
4. Serve API on `http://localhost:42069`

## API Endpoints

### REST API

#### Get all spreaders (with pagination)

```
GET /api/spreaders?limit=50&offset=0&sortBy=infectionCount&sortOrder=desc
```

Query parameters:
- `limit` (default: 50, max: 100)
- `offset` (default: 0)
- `owner` (filter by owner address)
- `sortBy` (tokenId | infectionCount | createdAt)
- `sortOrder` (asc | desc)
- `withInfections` (true | false)

#### Get single spreader

```
GET /api/spreaders/:tokenId
```

#### Get infections for spreader

```
GET /api/spreaders/:tokenId/infections?limit=50&offset=0
```

#### Get all infections

```
GET /api/infections?owner=0x...&parentTokenId=1
```

#### Get user's NFTs

```
GET /api/user/:address
```

Returns all spreaders and infections owned by address.

#### Get protocol statistics

```
GET /api/stats
```

Returns:
- Total spreaders
- Total infections
- Total infection contracts
- Average infections per spreader
- Most infectious spreader

### GraphQL API

GraphQL playground available at `http://localhost:42069/graphql`

Example query:

```graphql
query {
  spreaders(
    limit: 10
    orderBy: "infectionCount"
    orderDirection: "desc"
  ) {
    id
    tokenId
    owner
    dna
    infectionCount
    bodyType
    eyeChar
    hasCigarette
    name
    infections {
      id
      tokenId
      owner
      dna
    }
  }
}
```

## Schema

### Spreader

| Field | Type | Description |
|-------|------|-------------|
| id | string | Composite key: chainId:contractAddress:tokenId |
| tokenId | bigint | Token ID |
| owner | hex | Owner address |
| dna | bigint | Full DNA value |
| birthBlock | bigint | Block number at birth |
| infectionContractAddress | hex | Associated infection contract |
| bodyType | int | 0-5 (square, round, diamond, etc.) |
| bodyChar | int | 0-3 (█ ▓ ▒ ░) |
| eyeChar | int | 0-3 (● ◉ ◎ ○) |
| eyeSize | int | 0-1 (normal, mega) |
| antennaTip | int | 0-6 (● ◉ ○ ◎ ✦ ✧ ★) |
| armStyle | int | 0-1 (block, line) |
| legStyle | int | 0-1 (block, line) |
| hatType | int | 0-4 (none, top, bowler, crown, wizard) |
| hasCigarette | bool | Has cigarette or not |
| name | text | NFT name from metadata |
| description | text | NFT description |
| image | text | Image URI |
| animationUrl | text | Animation URI |
| infectionCount | int | Number of infections (derived) |
| createdAt | bigint | Timestamp of creation |
| updatedAt | bigint | Last update timestamp |

### Infection

| Field | Type | Description |
|-------|------|-------------|
| id | string | Composite key: chainId:contractAddress:tokenId |
| tokenId | bigint | Token ID |
| parentSpreaderId | string | Reference to parent spreader |
| parentTokenId | bigint | Parent token ID |
| infectionContractAddress | hex | Contract address |
| owner | hex | Owner address (victim) |
| dna | bigint | Full DNA value |
| infectedBy | hex | Address that triggered infection |
| birthBlock | bigint | Block number at birth |
| (DNA traits) | - | Same as Spreader |
| (metadata) | - | Same as Spreader |
| createdAt | bigint | Timestamp of creation |

### InfectionContract

| Field | Type | Description |
|-------|------|-------------|
| id | hex | Contract address (primary key) |
| parentSpreaderId | string | Reference to parent spreader |
| parentTokenId | bigint | Parent token ID |
| parentDna | bigint | Parent DNA |
| deployedAt | bigint | Deployment timestamp |
| deployedAtBlock | bigint | Deployment block number |

## Performance Benefits

### Before (Direct RPC Queries)
- ❌ Multiple RPC calls per spreader (tokenURI, ownerOf, getInfectionContract)
- ❌ Nested loops for infections (totalSupply → tokenURI × N)
- ❌ Metadata decoding on every request
- ❌ No pagination support
- ❌ Slow for large collections

### After (Indexer)
- ✅ Single database query for all data
- ✅ Pre-decoded DNA traits and metadata
- ✅ Indexed by owner, tokenId, traits
- ✅ Pagination built-in
- ✅ Sub-second response times

## Development

### Project structure

```
indexer/
├── src/
│   ├── index.ts              # Event handlers
│   ├── api/
│   │   └── index.ts          # REST API endpoints
│   └── utils/
│       ├── dna.ts            # DNA parsing utilities
│       └── metadata.ts       # Metadata decoding
├── abis/
│   ├── ProtocolitesMasterAbi.ts
│   ├── ProtocoliteFactoryAbi.ts
│   └── ProtocoliteInfectionAbi.ts
├── ponder.config.ts          # Contract configuration
├── ponder.schema.ts          # Database schema
└── package.json
```

### Adding new endpoints

Edit `/workspace/indexer/src/api/index.ts` and add your custom routes using Hono.

### Modifying schema

1. Edit `ponder.schema.ts`
2. Update event handlers in `src/index.ts`
3. Restart Ponder (it will rebuild the database)

## Deployment

Ponder can be deployed to:
- Railway
- Fly.io
- Any Docker-compatible platform

See [Ponder deployment docs](https://ponder.sh/docs/production/deploy) for details.

## Contract Addresses (Sepolia)

- ProtocolitesMaster: `0x35bea8249cde6c0e3ce9a3f3d0a526b1845b957d`
- ProtocoliteFactory: `0x4b7201b36a699de652249064ff3094c16eda161b`
- ProtocoliteRenderer: `0xb2c28e387518979324ea2a351762b247a6e60b3b`
- Start Block: `9440296`

## License

MIT
