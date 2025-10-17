# Deploy ASCII Renderer to Existing Protocolites

This guide shows how to deploy the ASCII renderer and update your existing Protocolites deployment to use it.

## Prerequisites

You need:
1. An existing ProtocolitesMaster contract already deployed
2. You must be the **owner** of that contract (to call `setRenderer`)
3. Your `.env` file configured with `PRIVATE_KEY` and `RPC_URL`

## Method 1: Deploy & Update Existing Contract (Recommended)

This deploys the ASCII renderer and updates your existing ProtocolitesMaster to use it.

### Step 1: Add Master Contract Address to .env

```bash
cd solidity
echo "MASTER_ADDRESS=0xYourMasterContractAddress" >> .env
```

Replace `0xYourMasterContractAddress` with your deployed ProtocolitesMaster address on Sepolia:
- ProtocolitesMaster: `0x8a94e7c81a4982a80405b5aead52155208b40d18`

### Step 2: Build with Optimizer (Required for ASCII)

The ASCII renderer is large and needs the optimizer enabled:

```bash
# Add to foundry.toml if not already there:
cat >> foundry.toml << 'EOF'
optimizer = true
optimizer_runs = 200
via_ir = true
EOF

# Build contracts
forge build
```

### Step 3: Deploy ASCII Renderer and Update

```bash
forge script script/DeployASCIIRenderer.s.sol:DeployASCIIRendererScript \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

This will:
1. Deploy the new `ProtocolitesRenderASCII` contract
2. Call `setRenderer()` on your existing ProtocolitesMaster
3. All **future** NFT renders will use ASCII art
4. **Existing** NFTs will also show ASCII art (metadata is generated on-demand)

### Step 4: Verify It Worked

Check a token's metadata:
```bash
cast call 0x8a94e7c81a4982a80405b5aead52155208b40d18 \
  "tokenURI(uint256)(string)" 1 \
  --rpc-url $RPC_URL
```

Decode the base64 data URL and you should see ASCII art instead of pixels!

## Method 2: Deploy New Complete System with ASCII

If you want a fresh deployment with ASCII from the start, create a new deployment script.

### Create DeployNewASCII.s.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolitesMaster} from "../src/ProtocolitesMaster.sol";
import {ProtocolitesRenderASCII} from "../src/ProtocolitesRenderASCII.sol";
import {ProtocoliteFactoryNew} from "../src/ProtocoliteFactoryNew.sol";

contract DeployNewASCIIScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying ASCII Protocolite system with address:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy ASCII renderer
        ProtocolitesRenderASCII renderer = new ProtocolitesRenderASCII();
        console.log("ProtocolitesRenderASCII deployed at:", address(renderer));

        // Deploy factory
        ProtocoliteFactoryNew factory = new ProtocoliteFactoryNew();
        console.log("ProtocoliteFactory deployed at:", address(factory));

        // Deploy master contract
        ProtocolitesMaster master = new ProtocolitesMaster();
        console.log("ProtocolitesMaster deployed at:", address(master));

        // Connect contracts
        master.setRenderer(address(renderer));
        master.setFactory(address(factory));
        factory.setRenderer(address(renderer));
        factory.transferOwnership(address(master));

        console.log("ASCII Protocolite System Ready!");

        vm.stopBroadcast();
    }
}
```

Then deploy:
```bash
forge script script/DeployNewASCII.s.sol:DeployNewASCIIScript \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

## How It Works

### Renderer Contracts

You now have **two renderer contracts**:
- `ProtocolitesRender.sol` - Generates pixelated art (smaller, 116 lines)
- `ProtocolitesRenderASCII.sol` - Generates ASCII art (larger, 385 lines)

Both implement the same interface:
```solidity
function tokenURI(uint256 tokenId, TokenData memory data)
    external view returns (string memory)
```

### Swapping Renderers

The ProtocolitesMaster contract has a `setRenderer()` function that only the owner can call:

```solidity
function setRenderer(address _renderer) external onlyOwner {
    renderer = ProtocolitesRender(_renderer);
}
```

When you call this, **all NFTs immediately use the new renderer** because `tokenURI()` is called on-demand, not stored.

### Key Differences

**Pixelated Renderer:**
- Generates HTML canvas with colored pixels
- Kids are 12×12, Parents are 24×24
- Smaller contract size (~30KB)
- Black background, colorful pixels

**ASCII Renderer:**
- Generates text-based ASCII art with characters: █ ▓ ▒ ░ ● ◉
- Kids are 16×16, Parents are 24×24
- Larger contract size (~90KB, needs optimizer)
- White background, colored text (6 families: red, green, blue, yellow, purple, cyan)
- Same DNA inheritance system (100% body type, 80% traits)

## Testing

After deployment, test that ASCII is working:

```bash
# Get tokenURI (returns base64-encoded JSON)
METADATA=$(cast call <MASTER_ADDRESS> "tokenURI(uint256)(string)" 1 --rpc-url $RPC_URL)

# Decode and view (requires node.js)
node << 'EOF'
const uri = process.argv[1];
const json = Buffer.from(uri.split(',')[1], 'base64').toString();
const data = JSON.parse(json);
const html = Buffer.from(data.animation_url.split(',')[1], 'base64').toString();
console.log(html.substring(0, 500)); // Should show HTML with ASCII generation code
EOF
```

## Reverting to Pixelated

If you want to switch back to pixelated rendering:

```bash
cast send <MASTER_ADDRESS> \
  "setRenderer(address)" <PIXELATED_RENDERER_ADDRESS> \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

## Troubleshooting

### "Stack too deep" error
Make sure `foundry.toml` has:
```toml
optimizer = true
optimizer_runs = 200
via_ir = true
```

### "Ownable: caller is not the owner"
Only the owner of ProtocolitesMaster can call `setRenderer()`. Check ownership:
```bash
cast call <MASTER_ADDRESS> "owner()(address)" --rpc-url $RPC_URL
```

### Contract won't verify on Etherscan
The ASCII renderer is large. Use these verification parameters:
- Compiler: 0.8.13
- Optimization: Yes, 200 runs
- Via IR: Yes

## Summary

To deploy ASCII renderer to your existing Protocolites:

```bash
# 1. Set environment variable
echo "MASTER_ADDRESS=0x8a94e7c81a4982a80405b5aead52155208b40d18" >> .env

# 2. Enable optimizer in foundry.toml
# (already done based on git status)

# 3. Build
forge build

# 4. Deploy and update
forge script script/DeployASCIIRenderer.s.sol:DeployASCIIRendererScript \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

That's it! All your Protocolites will now render as ASCII art.
