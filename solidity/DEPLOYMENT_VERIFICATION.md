# Protocolites Deployment Verification Guide

**Version:** 2.0.0 (Post-Refactor)  
**Date:** December 2024  
**Status:** Production Ready  

## 📋 Overview

This guide provides step-by-step instructions to deploy and verify the refactored Protocolites smart contract system. Follow these steps to ensure a successful deployment with all security features properly configured.

## 🔧 Pre-Deployment Checklist

### Environment Setup
```bash
# 1. Verify Foundry installation
forge --version
# Expected: forge 0.2.0 or later

# 2. Verify project setup
cd protocolites/solidity
forge build
# Expected: Successful compilation with no errors

# 3. Run critical tests
forge test --match-test test_EndToEndWorkflow
# Expected: [PASS] test_EndToEndWorkflow
```

### Environment Variables
```bash
# Required environment variables
export PRIVATE_KEY="0x..." # Your deployer private key
export RPC_URL="https://..." # Your RPC endpoint
export ETHERSCAN_API_KEY="..." # For contract verification (optional)
```

### Network Configuration
- **Mainnet**: 0.01 ETH spawn cost
- **Sepolia**: 0.001 ETH spawn cost (auto-detected)
- **Local/Anvil**: 0.01 ETH spawn cost

## 🚀 Deployment Steps

### Step 1: Deploy Contracts
```bash
# Deploy complete system
forge script script/DeployFreshASCII.s.sol:DeployFreshASCIIScript \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### Step 2: Record Contract Addresses
Expected output:
```
[OK] ASCII Renderer deployed at: 0x...
[OK] Factory deployed at: 0x...
[OK] Master deployed at: 0x...
[LINK] Master.setRenderer() called
[LINK] Master.setFactory() called
[SECURE] Factory ownership transferred to Master

=== DEPLOYMENT COMPLETE ===
Contract Addresses:
   Master Contract: 0x...
   Factory Contract: 0x...
   ASCII Renderer: 0x...
```

**Save these addresses for verification steps!**

## ✅ Post-Deployment Verification

### Contract Verification Checklist

#### 1. Master Contract Verification
```bash
# Replace MASTER_ADDRESS with your deployed address
cast call MASTER_ADDRESS "name()" --rpc-url $RPC_URL
# Expected: "Protocolites"

cast call MASTER_ADDRESS "symbol()" --rpc-url $RPC_URL
# Expected: "PROTO"

cast call MASTER_ADDRESS "totalSupply()" --rpc-url $RPC_URL
# Expected: 0 (initially)

cast call MASTER_ADDRESS "getSpawnCost()" --rpc-url $RPC_URL
# Expected: 10000000000000000 (0.01 ETH) or 1000000000000000 (0.001 ETH on Sepolia)
```

#### 2. Factory Contract Verification
```bash
# Replace FACTORY_ADDRESS with your deployed address
cast call FACTORY_ADDRESS "owner()" --rpc-url $RPC_URL
# Expected: Should match MASTER_ADDRESS

cast call FACTORY_ADDRESS "getDeployedCount()" --rpc-url $RPC_URL
# Expected: 0 (initially)
```

#### 3. Renderer Contract Verification
```bash
# Replace RENDERER_ADDRESS with your deployed address
cast call RENDERER_ADDRESS "owner()" --rpc-url $RPC_URL
# Expected: Your deployer address

cast call RENDERER_ADDRESS "renderScript()" --rpc-url $RPC_URL | cast to-ascii
# Expected: Long JavaScript string (default render script)
```

#### 4. Contract Connections Verification
```bash
# Verify master points to correct renderer
cast call MASTER_ADDRESS "renderer()" --rpc-url $RPC_URL
# Expected: Should match RENDERER_ADDRESS

# Verify master points to correct factory  
cast call MASTER_ADDRESS "factory()" --rpc-url $RPC_URL
# Expected: Should match FACTORY_ADDRESS
```

## 🧪 Functionality Testing

### Test 1: Spawn Parent NFT
```bash
# Test spawning (replace MASTER_ADDRESS and adjust value for network)
cast send MASTER_ADDRESS --value 0.01ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Verify NFT was minted
cast call MASTER_ADDRESS "totalSupply()" --rpc-url $RPC_URL
# Expected: 1

cast call MASTER_ADDRESS "ownerOf(uint256)(1)" --rpc-url $RPC_URL
# Expected: Your address
```

### Test 2: Verify Infection Contract Deployment
```bash
# Check infection contract was deployed for parent #1
cast call MASTER_ADDRESS "getInfectionContract(uint256)(1)" --rpc-url $RPC_URL
# Expected: Non-zero address (the deployed infection contract)

# Store infection contract address
INFECTION_ADDRESS=$(cast call MASTER_ADDRESS "getInfectionContract(uint256)(1)" --rpc-url $RPC_URL)
echo "Infection contract: $INFECTION_ADDRESS"
```

### Test 3: Test Infection Mechanism
```bash
# Trigger infection from parent #1
cast send MASTER_ADDRESS "infect(uint256)(1)" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Verify infection NFT was minted
cast call $INFECTION_ADDRESS "totalSupply()" --rpc-url $RPC_URL
# Expected: 1

cast call $INFECTION_ADDRESS "ownerOf(uint256)(1)" --rpc-url $RPC_URL
# Expected: Your address
```

### Test 4: Verify Metadata Generation
```bash
# Test parent NFT metadata
cast call MASTER_ADDRESS "tokenURI(uint256)(1)" --rpc-url $RPC_URL | cast to-ascii
# Expected: Long base64 string starting with "data:application/json;base64,"

# Test infection NFT metadata
cast call $INFECTION_ADDRESS "tokenURI(uint256)(1)" --rpc-url $RPC_URL | cast to-ascii
# Expected: Long base64 string starting with "data:application/json;base64,"
```

## 🔒 Security Verification

### Test 1: Reentrancy Protection
```bash
# Deploy malicious contract (this should fail)
# Create a contract that tries to call receive() in its receive() function
# Deployment and testing left as manual verification
```

### Test 2: Access Control
```bash
# Try to call admin function from non-owner (should fail)
# Use different private key than deployer
cast send RENDERER_ADDRESS "setRenderScript(string)('malicious code')" \
  --rpc-url $RPC_URL --private-key $OTHER_PRIVATE_KEY
# Expected: Transaction should revert with "Unauthorized"
```

### Test 3: Input Validation
```bash
# Try to set zero address (should fail)
cast send MASTER_ADDRESS "setRenderer(address)(0x0000000000000000000000000000000000000000)" \
  --rpc-url $RPC_URL --private-key $PRIVATE_KEY
# Expected: Transaction should revert with "Invalid renderer address"
```

## 📊 Health Check Dashboard

### Quick Status Check Script
```bash
#!/bin/bash
# Save as verify_deployment.sh

echo "🔍 Protocolites Deployment Health Check"
echo "================================="

echo "📋 Contract Addresses:"
echo "Master: $MASTER_ADDRESS"
echo "Factory: $FACTORY_ADDRESS" 
echo "Renderer: $RENDERER_ADDRESS"

echo ""
echo "🏠 Master Contract Status:"
echo "Name: $(cast call $MASTER_ADDRESS 'name()' --rpc-url $RPC_URL | cast to-ascii)"
echo "Supply: $(cast call $MASTER_ADDRESS 'totalSupply()' --rpc-url $RPC_URL)"
echo "Spawn Cost: $(cast call $MASTER_ADDRESS 'getSpawnCost()' --rpc-url $RPC_URL) wei"

echo ""
echo "🏭 Factory Status:"
echo "Owner: $(cast call $FACTORY_ADDRESS 'owner()' --rpc-url $RPC_URL)"
echo "Deployed Count: $(cast call $FACTORY_ADDRESS 'getDeployedCount()' --rpc-url $RPC_URL)"

echo ""
echo "🎨 Renderer Status:"
echo "Owner: $(cast call $RENDERER_ADDRESS 'owner()' --rpc-url $RPC_URL)"
echo "Script Length: $(cast call $RENDERER_ADDRESS 'renderScript()' --rpc-url $RPC_URL | wc -c)"

echo ""
echo "🔗 Connections:"
CONNECTED_RENDERER=$(cast call $MASTER_ADDRESS 'renderer()' --rpc-url $RPC_URL)
CONNECTED_FACTORY=$(cast call $MASTER_ADDRESS 'factory()' --rpc-url $RPC_URL)

if [ "$CONNECTED_RENDERER" = "$RENDERER_ADDRESS" ]; then
    echo "✅ Renderer connected correctly"
else
    echo "❌ Renderer connection mismatch"
fi

if [ "$CONNECTED_FACTORY" = "$FACTORY_ADDRESS" ]; then
    echo "✅ Factory connected correctly"  
else
    echo "❌ Factory connection mismatch"
fi

echo ""
echo "🎯 Deployment Status: $([ "$CONNECTED_RENDERER" = "$RENDERER_ADDRESS" ] && [ "$CONNECTED_FACTORY" = "$FACTORY_ADDRESS" ] && echo "✅ HEALTHY" || echo "❌ ISSUES DETECTED")"
```

## 🚨 Troubleshooting

### Common Issues

#### 1. "Insufficient funds for gas * price + value"
**Solution:** Ensure your deployer account has enough ETH for gas fees

#### 2. "Transaction reverted without a reason string"
**Solution:** Check that all environment variables are set correctly

#### 3. "Factory ownership not transferred"
**Solution:** Verify the factory.transferOwnership() call succeeded in deployment

#### 4. "Renderer connection failed"
**Solution:** Ensure renderer address is a valid contract, not EOA

#### 5. Contract verification fails
**Solution:** Ensure ETHERSCAN_API_KEY is set and valid

### Emergency Procedures

#### If Master Contract Fails
1. Do not transfer ownership yet
2. Redeploy master contract
3. Reconfigure connections
4. Transfer ownership after verification

#### If Factory/Renderer Fails
1. Deploy new factory/renderer
2. Use setFactory()/setRenderer() on master to update
3. Verify connections before use

## 📈 Monitoring & Maintenance

### Ongoing Monitoring
```bash
# Check system health daily
./verify_deployment.sh

# Monitor contract balances
cast balance $MASTER_ADDRESS --rpc-url $RPC_URL

# Check recent activity
cast logs --address $MASTER_ADDRESS --from-block latest-100 --rpc-url $RPC_URL
```

### Maintenance Tasks
- Monitor gas costs for optimizations
- Track NFT minting and infection rates
- Review renderer script updates
- Monitor for any unusual transaction patterns

## ✅ Deployment Success Criteria

Your deployment is successful when:

- [x] All contracts deployed and verified
- [x] Contract connections properly configured
- [x] Ownership properly transferred
- [x] Spawn functionality working
- [x] Infection mechanism working
- [x] Metadata generation working
- [x] Access controls functioning
- [x] Security features active

## 📞 Support

If you encounter issues:

1. **Check this guide** for troubleshooting steps
2. **Verify environment** variables and network connection
3. **Test on Sepolia** first before mainnet deployment
4. **Review contract addresses** for typos or mismatches

---

**Deployment Guide Status: ✅ COMPLETE**  
**Last Updated:** December 2024  
**Version Compatibility:** Protocolites v2.0.0+  
**Network Support:** Mainnet, Sepolia, Local/Anvil