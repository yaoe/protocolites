# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**PROTOCOLITE** is a generative ASCII art protocol with a viral NFT system. The project consists of:

1. **Solidity Contracts** (`/solidity`): Fully on-chain NFT system with inheritance mechanics
2. **Frontend** (`/frontend`): Next.js 15 web interface (currently scaffolded)
3. **Website Prototypes** (`/website-prototypes`): HTML/JS prototypes for testing rendering

## Repository Structure

This is a monorepo with workspace configuration at the root:
- `solidity/` - Foundry-based smart contract development
- `frontend/` - Next.js application (pnpm workspace)
- `website-prototypes/` - Standalone HTML prototypes and debugging tools

## Smart Contract Development

### Prerequisites
Foundry must be installed on the host machine (not available in Docker container).

### Commands

**Build & Test:**
```bash
cd /workspace/solidity
forge build                    # Compile contracts
forge test                     # Run all tests
forge test -vvv               # Verbose test output
forge test --match-test <name> # Run specific test
forge coverage                # Generate coverage report
forge fmt                     # Format Solidity code
```

**Deploy:**
```bash
# Set environment variables first
export PRIVATE_KEY="your_private_key"
export RPC_URL="your_rpc_url"

# Deploy fresh system
forge script script/Deploy.s.sol:DeployFreshASCIIScript \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

**Local Development:**
```bash
# Start local Anvil node (on host)
anvil

# Deploy to local node
forge script script/Deploy.s.sol:DeployFreshASCIIScript \
  --rpc-url http://localhost:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast
```

**Interact with Contracts:**
```bash
# Read-only calls
cast call $MASTER_ADDRESS "totalSupply()" --rpc-url $RPC_URL
cast call $MASTER_ADDRESS "tokenURI(uint256)" 1 --rpc-url $RPC_URL

# State-changing transactions
cast send $MASTER_ADDRESS --value 0.01ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY
cast send $MASTER_ADDRESS "infectRandom()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### Contract Architecture

**Deployment Order (Critical):**
1. `ProtocolitesRenderer` - Generates ASCII art and HTML
2. `ProtocoliteFactory` - Deploys infection contracts
3. `ProtocolitesMaster` - Main NFT contract
4. Connect: `master.setRenderer()`, `master.setFactory()`, `factory.transferOwnership(master)`

**Core Contracts:**
- `ProtocolitesMaster.sol` - ERC721 NFT with viral spawning logic
- `ProtocoliteFactory.sol` - Factory for deploying infection contracts
- `ProtocolitesRenderer.sol` - On-chain ASCII art renderer
- `ProtocoliteInfection.sol` - Individual soulbound infection contracts
- `libraries/DNAParser.sol` - DNA encoding/decoding with inheritance (moved from `src/` to `src/libraries/`)
- `libraries/TokenDataLib.sol` - Token data storage utilities

**Key Mechanisms:**
- **Spreaders (Parents)**: Spawned by sending 0.01 ETH (mainnet) or 0.001 ETH (Sepolia) to master contract
- **Infections (Children)**: Created by calling `infect()` or `infectRandom()` (free, just gas)
- **DNA System**: 17-bit encoding in uint256 with 80-100% inheritance rates
- **Fully On-Chain**: All metadata, art, and rendering logic stored on-chain

### DNA Inheritance Rules

**100% Inheritance (Never Mutates):**
- Body type (square, round, diamond, mushroom, invader, ghost)
- Arm style (block, line)
- Leg style (block, line)
- Family color (red, green, blue, yellow, purple, cyan)

**80% Inheritance (20% Mutation Rate):**
- Body fill character (█ ▓ ▒ ░)
- Eye character (● ◉ ◎ ○)
- Eye size (normal, mega)
- Antenna tip (● ◉ ○ ◎ ✦ ✧ ★)
- Hat type (if parent has hat)

**Random (Not Inherited):**
- Cigarette (10% chance per creature)
- Mouth style

### Security Considerations

All critical vulnerabilities have been addressed:
- Reentrancy guards on all payable functions
- Input validation (zero address, contract checks)
- DoS prevention (no unbounded arrays)
- Access control on admin functions
- Try/catch for external calls

**Never remove or modify:**
- Reentrancy guards (`nonReentrant` modifier)
- Input validation checks
- Factory ownership transfer to master contract

## Frontend Development

### Commands

```bash
cd /workspace/frontend
pnpm install    # Install dependencies (if needed)
pnpm dev        # Start dev server (port 3000)
pnpm build      # Build for production
pnpm start      # Start production server
```

### Stack
- **Framework**: Next.js 15.5.6 (App Router)
- **React**: 19.1.0
- **Styling**: Tailwind CSS v4
- **TypeScript**: Full type coverage
- **Build Tool**: Turbopack (via `--turbopack` flag)

### Current State
The frontend is a fresh Next.js scaffold. Implementation needs to connect to deployed contracts and render Protocolite creatures.

## Development Philosophy

From main README.md, the protocol follows these principles:

1. **Inheritance Over Randomness**: Children inherit 80-100% of parent traits
2. **Controlled Mutation**: 20% mutation rate for specific traits
3. **Minimalist Aesthetics**: Clean ASCII art, monospace characters
4. **Deterministic Generation**: Seed-based reproducibility
5. **Visual DNA**: Every trait visible in creature appearance
6. **Family Unity**: Color families maintain distinct identities

## Common Workflows

### Adding New Trait to DNA System

1. Update `TokenTraits` struct in `DNAParser.sol`
2. Add bit shift constants and masks
3. Implement `encode*` and `decode*` functions
4. Add inheritance logic in `inheritDNA()` function
5. Update renderer to display new trait
6. Add tests in `TestDNAParser.t.sol`

### Updating Renderer

The renderer is upgradeable via owner-only function:
```solidity
renderer.setRenderScript("new_javascript_code");
```

Test changes in `website-prototypes/` first before updating on-chain.

### Running Full Test Suite

```bash
cd /workspace/solidity
forge test -vvv 2>&1 | tee test-results.txt
```

Current status: 71/93 tests passing (76% pass rate). Core functionality fully tested.

## Important Notes

- **Forge not available in Docker**: All `forge` and `cast` commands must run on host machine
- **No hacks allowed**: Per user instructions, prefer clean solutions over workarounds
- **Monorepo structure**: Root `package.json` defines workspace, frontend is a workspace member
- **Branch**: Currently on `refactor-frontend` branch
- **DNAParser location**: Moved from `src/` to `src/libraries/` during refactor
- **Deployment script**: Use `Deploy.s.sol` (contains `DeployFreshASCIIScript` contract)
