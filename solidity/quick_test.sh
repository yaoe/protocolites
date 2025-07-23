#!/bin/bash

echo "🧬 TESTING PROTOCOLITE NFT GENERATION 🧬"
echo "========================================"

# Run the test and capture output
echo "Running Forge test to generate NFTs..."
forge test --match-test test_ViewParentNFT -vv > test_output.txt 2>&1

# Check if test passed
if [ $? -eq 0 ]; then
    echo "✅ Test passed! Extracting tokenURI..."
    
    # Extract the tokenURI (look for the data:application/json;base64 line)
    TOKEN_URI=$(grep "data:application/json;base64," test_output.txt | head -1 | sed 's/.*data:application/data:application/')
    
    if [ ! -z "$TOKEN_URI" ]; then
        echo "🎯 Found tokenURI! Decoding..."
        node decode_and_view.js "$TOKEN_URI"
    else
        echo "❌ Could not find tokenURI in test output"
        echo "Raw output:"
        cat test_output.txt
    fi
else
    echo "❌ Test failed!"
    cat test_output.txt
fi