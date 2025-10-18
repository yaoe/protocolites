#!/usr/bin/env node

const fs = require('fs');

// Get hex data from command line
const hexData = process.argv[2];

if (!hexData) {
    console.log(`
Usage: node visualize_from_hex.js <hex_data>

Example:
  TOKEN_URI=$(cast call CONTRACT_ADDRESS "tokenURI(uint256)" 1 --rpc-url $RPC_URL)
  node visualize_from_hex.js "$TOKEN_URI"
`);
    process.exit(1);
}

try {
    // Step 1: Remove 0x prefix if present
    const cleanHex = hexData.startsWith('0x') ? hexData.slice(2) : hexData;
    
    // Step 2: Decode hex to string
    // The data starts with offset (32 bytes) and length (32 bytes), then the actual string
    const offset = parseInt(cleanHex.slice(0, 64), 16) * 2; // Convert to hex chars
    const length = parseInt(cleanHex.slice(64, 128), 16) * 2; // Convert to hex chars
    const stringHex = cleanHex.slice(128, 128 + length);
    
    // Convert hex to string
    const tokenURI = Buffer.from(stringHex, 'hex').toString('utf8');
    
    console.log('🔍 Decoded tokenURI:', tokenURI.substring(0, 100) + '...');
    
    // Now process the tokenURI
    const base64Data = tokenURI.replace('data:application/json;base64,', '');
    const jsonStr = Buffer.from(base64Data, 'base64').toString();
    const metadata = JSON.parse(jsonStr);
    
    console.log('\n📋 NFT Metadata:');
    console.log('Name:', metadata.name);
    console.log('Description:', metadata.description);
    console.log('\n🎨 Attributes:');
    metadata.attributes.forEach(attr => {
        console.log(`  ${attr.trait_type}: ${attr.value}`);
    });
    
    if (metadata.animation_url) {
        // Extract the HTML from animation_url
        const htmlBase64 = metadata.animation_url.replace('data:text/html;base64,', '');
        const html = Buffer.from(htmlBase64, 'base64').toString();
        
        // Save the HTML
        const filename = 'nft_viewer.html';
        fs.writeFileSync(filename, html);
        
        console.log(`\n✅ NFT visualization saved to: ${filename}`);
        console.log('📂 Open this file in your browser to see the NFT!');
        
        // Check for potential issues
        console.log(`\n📊 HTML Stats:`);
        console.log(`  Size: ${html.length} characters`);
        console.log(`  Has canvas: ${html.includes('<canvas') ? 'Yes' : 'No'}`);
        console.log(`  Has script: ${html.includes('<script') ? 'Yes' : 'No'}`);
        
        // Show a preview of the HTML
        console.log('\n🔍 HTML Preview (first 500 chars):');
        console.log(html.substring(0, 500));
        
        // Save metadata too
        const metadataFilename = 'nft_metadata.json';
        fs.writeFileSync(metadataFilename, JSON.stringify(metadata, null, 2));
        
    } else {
        console.log('\n❌ No animation_url found in metadata!');
    }
    
} catch (error) {
    console.error('\n❌ Error processing hex data:', error.message);
    console.error('Stack:', error.stack);
    
    // Save raw data for debugging
    fs.writeFileSync('debug_raw_hex.txt', hexData);
    console.log('\n🔍 Raw hex data saved to debug_raw_hex.txt for inspection');
}