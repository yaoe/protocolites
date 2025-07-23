# Protocolites NFT System

An on-chain generative NFT system where Protocolites can breed kids or spawn new colonies.

## Architecture

### Smart Contracts

1. **ProtocoliteFactory.sol** - Factory contract that deploys new Protocolite contracts
   - Tracks all spawned Protocolite contracts
   - Sets up new contracts with correct renderer

2. **Protocolites.sol** - Main NFT contract with breeding logic
   - Parent Protocolites (24x24): Can breed kids or spawn new colonies
   - Kid Protocolites (12x12): Cannot breed, inherit parent's genetics
   - `breed(tokenId)` with 0 ETH: Mints a kid to msg.sender
   - `breed(tokenId)` with 0.1 ETH: Spawns a new Protocolite contract

3. **ProtocolitesRender.sol** - On-chain renderer with upgradeable script
   - Generates fully on-chain HTML/Canvas animations
   - Kids inherit parent's color palette
   - Script can be updated by owner for new visual features

## Key Features

- **Fully On-Chain**: All rendering happens on-chain with no external dependencies
- **Genetic Inheritance**: Kids inherit colors from their parent
- **Factory Pattern**: New colonies are spawned through a factory contract
- **Upgradeable Visuals**: Rendering script can be updated without changing NFT contract

## Usage

### Installation
```bash
# Install Foundry if not already installed
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Build
```bash
forge build
```

### Test
```bash
forge test
forge test -vvv  # Verbose output
```

### Deploy
```bash
forge script script/Protocolites.s.sol:ProtocoliteScript --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Interacting with Contracts

### Mint a Parent Protocolite (Owner only)
```solidity
protocolites.mint(recipientAddress);
```

### Breed a Kid (Anyone can call on their NFT)
```solidity
// Call with 0 ETH to mint a kid
protocolites.breed(parentTokenId);
```

### Spawn a New Colony (Anyone can call on their NFT)
```solidity
// Call with 0.1 ETH to spawn new contract
protocolites.breed{value: 0.1 ether}(parentTokenId);
```

### Update Rendering Script (Owner only)
```solidity
renderer.setRenderScript(newScriptString);
```

## Genetic System

- DNA is generated from: `keccak256(user address, tokenId, block number)`
- Colors are derived from DNA hash
- Kids inherit parent's color palette but have their own unique DNA
- Visual traits (eyes, mouth, body shape) are determined by DNA

## Gas Optimization

- Uses Solady's optimized ERC721 implementation
- Minimal storage for token data
- Efficient rendering using string concatenation

## Security Considerations

- Only NFT owners can breed from their tokens
- Factory pattern prevents malicious contract deployment
- Renderer script updates are owner-restricted
- ETH refunds handled safely with checks-effects-interactions pattern