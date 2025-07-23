#!/bin/bash

echo "🧪 QUICK PROTOCOLITE TEST 🧪"
echo "============================"

# Check if deployment addresses exist
if [ ! -f .env.deployment ]; then
    echo "❌ .env.deployment not found!"
    exit 1
fi

# Source files
source .env.deployment
source .env

echo "🎯 Contract addresses:"
echo "Protocolites: $PROTOCOLITES_ADDRESS"
echo "Renderer: $RENDERER_ADDRESS" 
echo "Factory: $FACTORY_ADDRESS"
echo ""

# Simple contract check
echo "1️⃣ Checking if contracts have code..."
CODE_SIZE=$(cast code $PROTOCOLITES_ADDRESS --rpc-url $RPC_URL | wc -c)
if [ $CODE_SIZE -gt 10 ]; then
    echo "✅ Protocolites contract has code ($CODE_SIZE chars)"
else
    echo "❌ Protocolites contract has no code - deployment may have failed"
    echo "🔍 Checking transaction..."
    cast tx 0xe1e04ed36fed288b0f27488bed76f9c416b4177fa4ac97d1e46e934eabfc8413 --rpc-url $RPC_URL
    exit 1
fi

# Check owner
OWNER=$(cast call $PROTOCOLITES_ADDRESS "owner()(address)" --rpc-url $RPC_URL)
echo "✅ Contract owner: $OWNER"

# Try minting
echo ""
echo "2️⃣ Minting a Protocolite..."
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)
echo "Minting to: $DEPLOYER"

cast send $PROTOCOLITES_ADDRESS "mint(address)" $DEPLOYER --private-key $PRIVATE_KEY --rpc-url $RPC_URL

echo ""
echo "3️⃣ Checking total supply..."
SUPPLY=$(cast call $PROTOCOLITES_ADDRESS "totalSupply()(uint256)" --rpc-url $RPC_URL)
echo "Total supply: $(cast to-dec $SUPPLY)"

if [ $(cast to-dec $SUPPLY) -gt 0 ]; then
    echo ""
    echo "4️⃣ Getting tokenURI..."
    URI=$(cast call $PROTOCOLITES_ADDRESS "tokenURI(uint256)" 1 --rpc-url $RPC_URL | sed 's/^"//;s/"$//')
    
    echo "TokenURI length: ${#URI}"
    echo "First 100 chars: ${URI:0:100}..."
    
    # Save for manual inspection
    echo "$URI" > token_uri_raw.txt
    echo "✅ Full URI saved to token_uri_raw.txt"
fi

echo ""
echo "🎉 Quick test complete!"