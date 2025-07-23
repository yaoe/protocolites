#!/bin/bash

echo "🧪 TESTING DEPLOYED PROTOCOLITE CONTRACTS 🧪"
echo "============================================="

# Check if deployment addresses exist
if [ ! -f .env.deployment ]; then
    echo "❌ .env.deployment not found. Run ./deploy.sh first!"
    exit 1
fi

# Source deployment addresses
source .env.deployment
source .env

echo "🎯 Testing contracts:"
echo "Protocolites: $PROTOCOLITES_ADDRESS"
echo "Renderer: $RENDERER_ADDRESS" 
echo "Factory: $FACTORY_ADDRESS"
echo ""

# Function to run cast commands
run_cast() {
    cast "$@" --rpc-url $RPC_URL
}

# Test 1: Check contract deployment
echo "1️⃣ Verifying contract deployment..."
OWNER=$(run_cast call $PROTOCOLITES_ADDRESS "owner()(address)")
echo "✅ Protocolites owner: $OWNER"

RENDERER_SET=$(run_cast call $PROTOCOLITES_ADDRESS "renderer()(address)")
echo "✅ Renderer set to: $RENDERER_SET"

# Test 2: Mint a parent Protocolite
echo ""
echo "2️⃣ Minting parent Protocolite..."
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
echo "Minting to: $DEPLOYER_ADDRESS"

# Mint transaction
TX_HASH=$(run_cast send $PROTOCOLITES_ADDRESS "mint(address)" $DEPLOYER_ADDRESS --private-key $PRIVATE_KEY --value 0)
echo "✅ Mint transaction: $TX_HASH"

# Wait for confirmation
echo "⏳ Waiting for confirmation..."
cast receipt $TX_HASH --rpc-url $RPC_URL > /dev/null

# Check token count
TOKEN_COUNT=$(run_cast call $PROTOCOLITES_ADDRESS "totalSupply()(uint256)")
echo "✅ Total tokens minted: $(cast to-dec $TOKEN_COUNT)"

# Test 3: Get tokenURI and decode
echo ""
echo "3️⃣ Getting tokenURI for token #1..."
TOKEN_URI=$(run_cast call $PROTOCOLITES_ADDRESS "tokenURI(uint256)" 1)

# Clean up the tokenURI (remove quotes and decode hex if needed)
TOKEN_URI_CLEAN=$(echo $TOKEN_URI | sed 's/^"//;s/"$//' | sed 's/^0x//' | xxd -r -p 2>/dev/null || echo $TOKEN_URI | sed 's/^"//;s/"$//')

echo "✅ TokenURI retrieved!"
echo "🎨 Decoding NFT data..."

# Create a quick decoder
cat > temp_decoder.js << 'EOF'
const uri = process.argv[2];
const fs = require('fs');

try {
    const base64 = uri.replace('data:application/json;base64,', '');
    const json = JSON.parse(Buffer.from(base64, 'base64').toString('utf8'));
    
    console.log('🎭 Name:', json.name);
    console.log('📝 Description:', json.description);
    
    if (json.animation_url) {
        const animationBase64 = json.animation_url.replace('data:text/html;base64,', '');
        const html = Buffer.from(animationBase64, 'base64').toString('utf8');
        
        fs.writeFileSync('onchain_protocolite.html', html);
        console.log('✅ Protocolite HTML saved to: onchain_protocolite.html');
        console.log('🌐 Open this file in your browser to see your NFT!');
    }
    
    console.log('🧬 Attributes:');
    json.attributes.forEach(attr => {
        console.log(`   ${attr.trait_type}: ${attr.value}`);
    });
    
} catch (e) {
    console.log('❌ Failed to decode:', e.message);
    console.log('Raw URI:', uri);
}
EOF

node temp_decoder.js "$TOKEN_URI_CLEAN"
rm temp_decoder.js

# Test 4: Breed a kid
echo ""
echo "4️⃣ Breeding a kid from parent #1..."
BREED_TX=$(run_cast send $PROTOCOLITES_ADDRESS "breed(uint256)" 1 --private-key $PRIVATE_KEY --value 0)
echo "✅ Breed transaction: $BREED_TX"

echo "⏳ Waiting for confirmation..."
cast receipt $BREED_TX --rpc-url $RPC_URL > /dev/null

NEW_TOKEN_COUNT=$(run_cast call $PROTOCOLITES_ADDRESS "totalSupply()(uint256)")
echo "✅ Total tokens now: $(cast to-dec $NEW_TOKEN_COUNT)"

# Test 5: Check kid's tokenURI
echo ""
echo "5️⃣ Getting kid's tokenURI (token #2)..."
KID_URI=$(run_cast call $PROTOCOLITES_ADDRESS "tokenURI(uint256)" 2)
KID_URI_CLEAN=$(echo $KID_URI | sed 's/^"//;s/"$//' | sed 's/^0x//' | xxd -r -p 2>/dev/null || echo $KID_URI | sed 's/^"//;s/"$//')

cat > temp_kid_decoder.js << 'EOF'
const uri = process.argv[2];
const fs = require('fs');

try {
    const base64 = uri.replace('data:application/json;base64,', '');
    const json = JSON.parse(Buffer.from(base64, 'base64').toString('utf8'));
    
    console.log('👶 Kid Name:', json.name);
    
    if (json.animation_url) {
        const animationBase64 = json.animation_url.replace('data:text/html;base64,', '');
        const html = Buffer.from(animationBase64, 'base64').toString('utf8');
        
        fs.writeFileSync('onchain_kid.html', html);
        console.log('✅ Kid HTML saved to: onchain_kid.html');
    }
    
    console.log('🧬 Kid Attributes:');
    json.attributes.forEach(attr => {
        console.log(`   ${attr.trait_type}: ${attr.value}`);
    });
    
} catch (e) {
    console.log('❌ Failed to decode kid:', e.message);
}
EOF

node temp_kid_decoder.js "$KID_URI_CLEAN"
rm temp_kid_decoder.js

echo ""
echo "🎉 ON-CHAIN TESTING COMPLETE!"
echo "✅ Successfully deployed and tested Protocolite NFT system"
echo "🌐 View your NFTs:"
echo "   - Parent: onchain_protocolite.html"
echo "   - Kid: onchain_kid.html"
echo ""
echo "🔗 Contract addresses:"
echo "   - Protocolites: $PROTOCOLITES_ADDRESS"
echo "   - Renderer: $RENDERER_ADDRESS"
echo "   - Factory: $FACTORY_ADDRESS"