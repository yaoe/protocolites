#!/bin/bash

echo "🧬 PROTOCOLITE NFT DEPLOYMENT SCRIPT 🧬"
echo "======================================"

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Please create .env file with:"
    echo "PRIVATE_KEY=your_private_key_here"
    echo "RPC_URL=your_rpc_url_here"
    echo "ETHERSCAN_API_KEY=your_etherscan_key_here (optional)"
    exit 1
fi

# Source environment variables
source .env

# Check required variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    echo "❌ RPC_URL not set in .env"
    exit 1
fi

echo "🚀 Deploying to network: $RPC_URL"
echo "📝 Using deployer private key: ${PRIVATE_KEY:0:10}..."

# Deploy contracts
forge script script/Deploy.s.sol:DeployFreshASCIIScript \
    --rpc-url $RPC_URL \
    --broadcast \
    --verify \
    -vvvv

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ DEPLOYMENT SUCCESSFUL!"
    echo "🎯 Contract addresses saved to .env.deployment"
    echo ""
    echo "Next steps:"
    echo "1. Source the deployment file: source .env.deployment"
    echo "2. Run: ./test_onchain.sh to test your deployed contracts"
    echo "3. Mint your first Protocolite!"
else
    echo ""
    echo "❌ DEPLOYMENT FAILED!"
    echo "Check the error messages above"
fi
