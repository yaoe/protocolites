# 🧬 Protocolite NFT Deployment Guide

## Quick Start

### 1. Setup Environment
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your values:
# - PRIVATE_KEY: Your wallet private key (without 0x)
# - RPC_URL: Your RPC endpoint
# - ETHERSCAN_API_KEY: For contract verification (optional)
```

### 2. Deploy Contracts
```bash
# Deploy to your configured network
./deploy.sh
```

### 3. Test On-Chain
```bash
# Test deployed contracts
./test_onchain.sh
```

## Recommended Networks

### Testnets (Recommended for testing)
- **Sepolia**: Low cost, reliable
- **Base Sepolia**: Ultra low cost, fast
- **Polygon Mumbai**: Very low cost

### Mainnet Options
- **Ethereum**: High cost but maximum compatibility
- **Base**: Low cost, fast, Ethereum-compatible
- **Polygon**: Very low cost, widely supported

## Step-by-Step Deployment

### 1. Environment Setup

Create `.env` file:
```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your_key

# Optional for verification
ETHERSCAN_API_KEY=your_key_here
```

**Security Note**: Never commit your `.env` file or share your private key!

### 2. Deploy Contracts

```bash
# Make sure you have some ETH for gas
./deploy.sh
```

This deploys:
- `ProtocolitesRender`: On-chain HTML renderer
- `ProtocoliteFactory`: Factory for spawning new collections  
- `Protocolites`: Main NFT contract

### 3. Verify Deployment

The deployment script automatically:
- Connects all contracts together
- Sets up proper permissions
- Saves addresses to `.env.deployment`

### 4. Test Your NFTs

```bash
# Run comprehensive on-chain tests
./test_onchain.sh
```

This will:
- Mint a parent Protocolite
- Breed a kid from the parent
- Decode and save HTML files for viewing
- Verify all contract interactions

## Viewing Your NFTs

After testing, you'll have HTML files:
- `onchain_protocolite.html` - Your parent NFT
- `onchain_kid.html` - The bred kid NFT

Open these in any web browser to see your on-chain generative art!

## Manual Contract Interaction

### Using Cast Commands

```bash
# Source your deployment addresses
source .env.deployment

# Mint a new parent (costs 0 ETH)
cast send $PROTOCOLITES_ADDRESS "mint(address)" YOUR_ADDRESS --private-key $PRIVATE_KEY --rpc-url $RPC_URL

# Breed a kid (costs 0 ETH)
cast send $PROTOCOLITES_ADDRESS "breed(uint256)" 1 --private-key $PRIVATE_KEY --rpc-url $RPC_URL --value 0

# Spawn new collection (costs 0.1 ETH)
cast send $PROTOCOLITES_ADDRESS "breed(uint256)" 1 --private-key $PRIVATE_KEY --rpc-url $RPC_URL --value 0.1ether

# Get tokenURI
cast call $PROTOCOLITES_ADDRESS "tokenURI(uint256)" 1 --rpc-url $RPC_URL

# Check total supply
cast call $PROTOCOLITES_ADDRESS "totalSupply()" --rpc-url $RPC_URL
```

### Key Functions

- `mint(address to)` - Mint new parent Protocolite
- `breed(uint256 parentId)` - With 0 ETH: breed kid, with 0.1 ETH: spawn collection
- `tokenURI(uint256 tokenId)` - Get NFT metadata and rendering
- `totalSupply()` - Get total minted count

## Troubleshooting

### Common Issues

1. **"insufficient funds"**: Add ETH to your wallet
2. **"nonce too low"**: Wait a moment and retry
3. **"execution reverted"**: Check token exists and you own it

### Gas Estimation

Approximate gas costs:
- Deploy all contracts: ~2-3M gas
- Mint parent: ~200K gas  
- Breed kid: ~300K gas
- Spawn collection: ~3M gas

### Network-Specific Notes

**Sepolia**: Use https://sepoliafaucet.com for test ETH
**Base**: Very fast, ~1-2 second confirmation
**Polygon**: Sometimes requires higher gas price

## Contract Verification

Verification happens automatically if you set `ETHERSCAN_API_KEY` in `.env`.

Manual verification:
```bash
forge verify-contract CONTRACT_ADDRESS src/Protocolites.sol:Protocolites --etherscan-api-key $ETHERSCAN_API_KEY --rpc-url $RPC_URL
```

## Security Notes

- Never share your private key
- Test on testnets first  
- Verify contract addresses before large transactions
- The renderer is upgradeable by the owner (you)

## What's Next?

1. **Update Renderer**: Call `setRenderScript()` to upgrade the art algorithm
2. **Build UI**: Create a web interface for minting/breeding  
3. **Analytics**: Track breeding patterns and generational trees
4. **Marketplace**: List your Protocolites on OpenSea/LooksRare

Your Protocolites are now live on-chain and ready to breed! 🧬✨