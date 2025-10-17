# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This workspace contains two main components:

1. **HTML Files** - A collection of HTML files in the root directory that appear to be variations of a "Claude" themed interactive application
2. **Solidity Project** - A Foundry-based smart contract project located in `/workspace/solidity/` implementing an NFT contract called "Protocolites"

## Solidity Development Commands

When working in the `/workspace/solidity/` directory:

### Build Commands
```bash
forge build      # Compile all smart contracts
forge fmt        # Format Solidity code according to Foundry standards
```

### Testing Commands
```bash
forge test                    # Run all tests
forge test -vvv              # Run tests with verbose output
forge test --match-test <name>  # Run specific test by name
forge test --match-contract <name>  # Run tests for specific contract
```

### Other Useful Commands
```bash
forge snapshot   # Generate gas snapshots
anvil           # Start local Ethereum node
forge script script/Protocolites.s.sol:ProtocoliteScript --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>  # Deploy contracts
```

## Architecture Overview

### Smart Contract Architecture

The Protocolites project follows a modular NFT architecture:

1. **Protocolites.sol** - Main ERC721 NFT contract that:
   - Inherits from Solady's optimized ERC721 implementation
   - Uses Ownable for access control
   - Delegates rendering logic to a separate contract via the `render` address

2. **ProtocolitesRender.sol** - Handles on-chain metadata generation:
   - Generates fully on-chain metadata with embedded HTML animation
   - Returns base64-encoded JSON containing the animation as data URI
   - The animation references a JavaScript variable `arborTokenId` containing the token ID

3. **Dependencies**:
   - Uses Solady library for gas-optimized implementations
   - Forge-std for testing infrastructure

### Key Design Patterns

- **Separation of Concerns**: Rendering logic is separated from the NFT contract, allowing for upgradeable metadata without changing the core NFT
- **On-chain Metadata**: All metadata is generated on-chain, including HTML animations embedded as data URIs
- **Gas Optimization**: Uses Solady's optimized contracts instead of OpenZeppelin

### Testing Approach

Tests are located in `/workspace/solidity/test/` and use Foundry's testing framework. The current test suite validates the tokenURI functionality by deploying both contracts and linking them.

### Common Issues

- When overriding functions from Solady's ERC721, remember to add the `override` specifier
- The `_exists` function in particular needs: `function _exists(uint256 tokenId) internal view virtual override returns (bool)`