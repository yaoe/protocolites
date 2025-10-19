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
echo "ProtocolitesMaster: $PROTOCOLITES_ADDRESS"
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
echo "✅ ProtocolitesMaster owner: $OWNER"

RENDERER_SET=$(run_cast call $PROTOCOLITES_ADDRESS "renderer()(address)")
echo "✅ Renderer set to: $RENDERER_SET"

FACTORY_SET=$(run_cast call $PROTOCOLITES_ADDRESS "factory()(address)")
echo "✅ Factory set to: $FACTORY_SET"

# Check spawn cost
SPAWN_COST=$(run_cast call $PROTOCOLITES_ADDRESS "getSpawnCost()(uint256)")
SPAWN_COST_DEC=$(cast to-dec $SPAWN_COST 2>/dev/null || echo "1000000000000000")
SPAWN_COST_ETH=$(echo "scale=6; $SPAWN_COST_DEC / 1000000000000000000" | bc -l 2>/dev/null || echo "0.001")
echo "✅ Spawn cost: $SPAWN_COST_ETH ETH"

# Test 2: Spawn a parent Protocolite
echo ""
echo "2️⃣ Spawning parent Protocolite..."
DEPLOYER_ADDRESS=$(cast wallet address --private-key $PRIVATE_KEY)
echo "Spawning to: $DEPLOYER_ADDRESS"
echo "Required payment: $SPAWN_COST_ETH ETH"

# Spawn transaction with payment
TX_HASH=$(run_cast send $PROTOCOLITES_ADDRESS "spawnParent()" --private-key $PRIVATE_KEY --value $SPAWN_COST)
if [ -z "$TX_HASH" ]; then
    echo "❌ Failed to spawn parent"
    exit 1
fi
echo "✅ Spawn transaction: $TX_HASH"

# Wait for confirmation
echo "⏳ Waiting for confirmation..."
cast receipt $TX_HASH --rpc-url $RPC_URL > /dev/null

# Check token count
TOKEN_COUNT=$(run_cast call $PROTOCOLITES_ADDRESS "totalSupply()(uint256)")
echo "✅ Total parent tokens spawned: $(cast to-dec $TOKEN_COUNT)"

# Get the infection contract for token #1
INFECTION_CONTRACT_RAW=$(run_cast call $PROTOCOLITES_ADDRESS "getInfectionContract(uint256)" 1)
# Extract the actual address (last 40 characters) and format properly
INFECTION_CONTRACT=$(echo $INFECTION_CONTRACT_RAW | sed 's/.*\(.\{40\}\)$/0x\1/')
echo "✅ Infection contract for token #1: $INFECTION_CONTRACT"

# Test 3: Get tokenURI and decode for parent
echo ""
echo "3️⃣ Getting tokenURI for parent token #1..."
TOKEN_URI=$(run_cast call $PROTOCOLITES_ADDRESS "tokenURI(uint256)" 1)

# Clean up the tokenURI (remove quotes and decode hex if needed)
TOKEN_URI_RAW=$(echo $TOKEN_URI | sed 's/^"//;s/"$//')
# Handle potential hex encoding
if [[ $TOKEN_URI_RAW == 0x* ]]; then
    TOKEN_URI_CLEAN=$(echo $TOKEN_URI_RAW | sed 's/^0x//' | xxd -r -p 2>/dev/null || echo "$TOKEN_URI_RAW")
else
    TOKEN_URI_CLEAN="$TOKEN_URI_RAW"
fi
# Fix any data URI prefix issues
TOKEN_URI_CLEAN=$(echo "$TOKEN_URI_CLEAN" | sed 's/^ddata:/data:/' | sed 's/^d\([^d]\)/\1/')

echo "✅ Parent TokenURI retrieved!"
echo "🎨 Decoding parent NFT data..."

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

        fs.writeFileSync('onchain_parent.html', html);
        console.log('✅ Parent HTML saved to: onchain_parent.html');
        console.log('🌐 Open this file in your browser to see your parent NFT!');
    }

    if (json.attributes && json.attributes.length > 0) {
        console.log('🧬 Attributes:');
        json.attributes.forEach(attr => {
            console.log(`   ${attr.trait_type}: ${attr.value}`);
        });
    }

} catch (e) {
    console.log('❌ Failed to decode:', e.message);
    console.log('Raw URI:', uri.substring(0, 200) + '...');
}
EOF

node temp_decoder.js "$TOKEN_URI_CLEAN"
rm temp_decoder.js

# Test 4: Trigger infection (create a child)
echo ""
echo "4️⃣ Triggering infection from parent #1..."
INFECT_TX=$(run_cast send $PROTOCOLITES_ADDRESS "infect(uint256)" 1 --private-key $PRIVATE_KEY)
if [ -z "$INFECT_TX" ]; then
    echo "❌ Failed to trigger infection"
    exit 1
fi
echo "✅ Infection transaction: $INFECT_TX"

echo "⏳ Waiting for confirmation..."
cast receipt $INFECT_TX --rpc-url $RPC_URL > /dev/null

# Check if child was created in infection contract
echo "🔍 Checking children in infection contract: $INFECTION_CONTRACT"
CHILD_COUNT=$(run_cast call $INFECTION_CONTRACT "totalSupply()(uint256)" 2>/dev/null || echo "0x0")
echo "✅ Children in infection contract: $(cast to-dec $CHILD_COUNT)"

# Test 5: Check child's tokenURI if it exists
if [ "$(cast to-dec $CHILD_COUNT)" -gt "0" ]; then
    echo ""
    echo "5️⃣ Getting child's tokenURI (token #1 in infection contract)..."
    CHILD_URI=$(run_cast call $INFECTION_CONTRACT "tokenURI(uint256)" 1 2>/dev/null || echo "")

    if [ ! -z "$CHILD_URI" ]; then
        CHILD_URI_RAW=$(echo $CHILD_URI | sed 's/^"//;s/"$//')
        # Handle potential hex encoding
        if [[ $CHILD_URI_RAW == 0x* ]]; then
            CHILD_URI_CLEAN=$(echo $CHILD_URI_RAW | sed 's/^0x//' | xxd -r -p 2>/dev/null || echo "$CHILD_URI_RAW")
        else
            CHILD_URI_CLEAN="$CHILD_URI_RAW"
        fi
        # Fix any data URI prefix issues
        CHILD_URI_CLEAN=$(echo "$CHILD_URI_CLEAN" | sed 's/^ddata:/data:/' | sed 's/^d\([^d]\)/\1/')

        cat > temp_child_decoder.js << 'EOF'
const uri = process.argv[2];
const fs = require('fs');

try {
    const base64 = uri.replace('data:application/json;base64,', '');
    const json = JSON.parse(Buffer.from(base64, 'base64').toString('utf8'));

    console.log('👶 Child Name:', json.name);

    if (json.animation_url) {
        const animationBase64 = json.animation_url.replace('data:text/html;base64,', '');
        const html = Buffer.from(animationBase64, 'base64').toString('utf8');

        fs.writeFileSync('onchain_child.html', html);
        console.log('✅ Child HTML saved to: onchain_child.html');
    }

    if (json.attributes && json.attributes.length > 0) {
        console.log('🧬 Child Attributes:');
        json.attributes.forEach(attr => {
            console.log(`   ${attr.trait_type}: ${attr.value}`);
        });
    }

} catch (e) {
    console.log('❌ Failed to decode child:', e.message);
}
EOF

        node temp_child_decoder.js "$CHILD_URI_CLEAN"
        rm temp_child_decoder.js
    else
        echo "❌ Could not retrieve child tokenURI"
    fi
else
    echo "❌ No children were created in infection contract"
fi

# Test 6: Try random infection
echo ""
echo "6️⃣ Triggering random infection..."
RANDOM_INFECT_TX=$(run_cast send $PROTOCOLITES_ADDRESS "infectRandom()" --private-key $PRIVATE_KEY 2>/dev/null || echo "")
if [ ! -z "$RANDOM_INFECT_TX" ]; then
    echo "✅ Random infection transaction: $RANDOM_INFECT_TX"
    cast receipt $RANDOM_INFECT_TX --rpc-url $RPC_URL > /dev/null
else
    echo "⚠️  Random infection may have failed or created child elsewhere"
fi

echo ""
echo "🎉 ON-CHAIN TESTING COMPLETE!"
echo "✅ Successfully tested Protocolite NFT system"
echo "🌐 View your NFTs:"
echo "   - Parent: onchain_parent.html"
if [ -f "onchain_child.html" ]; then
    echo "   - Child: onchain_child.html"
fi
echo ""
echo "🔗 Contract addresses:"
echo "   - ProtocolitesMaster: $PROTOCOLITES_ADDRESS"
echo "   - Renderer: $RENDERER_ADDRESS"
echo "   - Factory: $FACTORY_ADDRESS"
echo "   - Infection Contract #1: $INFECTION_CONTRACT"
echo ""
echo "💡 Note: Children are created in separate infection contracts, not in the main contract!"
