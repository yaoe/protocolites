#!/usr/bin/env node

const fs = require('fs');

// Get tokenURI from command line
const tokenURI = process.argv[2];

if (!tokenURI || !tokenURI.startsWith('data:')) {
    console.log(`
Usage: node visualize_nft.js <tokenURI>

Example:
  node visualize_nft.js "data:application/json;base64,..."
  
Or get it directly from contract:
  TOKEN_URI=$(cast call CONTRACT_ADDRESS "tokenURI(uint256)" 1 --rpc-url $RPC_URL)
  node visualize_nft.js "$TOKEN_URI"
`);
    process.exit(1);
}

try {
    // Step 1: Decode the JSON metadata
    const base64Data = tokenURI.replace('data:application/json;base64,', '');
    const jsonStr = Buffer.from(base64Data, 'base64').toString();
    const metadata = JSON.parse(jsonStr);
    
    console.log('📋 NFT Metadata:');
    console.log('Name:', metadata.name);
    console.log('Description:', metadata.description);
    console.log('\n🎨 Attributes:');
    metadata.attributes.forEach(attr => {
        console.log(`  ${attr.trait_type}: ${attr.value}`);
    });
    
    if (metadata.animation_url) {
        // Step 2: Extract the HTML from animation_url
        const htmlBase64 = metadata.animation_url.replace('data:text/html;base64,', '');
        const html = Buffer.from(htmlBase64, 'base64').toString();
        
        // Step 3: Save the HTML
        const filename = 'nft_viewer.html';
        fs.writeFileSync(filename, html);
        
        console.log(`\n✅ NFT visualization saved to: ${filename}`);
        console.log('📂 Open this file in your browser to see the NFT!');
        
        // Optional: Show HTML stats
        console.log(`\n📊 HTML Stats:`);
        console.log(`  Size: ${html.length} characters`);
        console.log(`  Has canvas: ${html.includes('<canvas') ? 'Yes' : 'No'}`);
        console.log(`  Has script: ${html.includes('<script') ? 'Yes' : 'No'}`);
        
        // Check for potential issues
        if (html.length < 100) {
            console.log('\n⚠️  WARNING: HTML seems too short!');
        }
        if (!html.includes('canvas')) {
            console.log('\n⚠️  WARNING: No canvas element found!');
        }
        
        // Save metadata too
        const metadataFilename = 'nft_metadata.json';
        fs.writeFileSync(metadataFilename, JSON.stringify(metadata, null, 2));
        console.log(`\n📋 Metadata saved to: ${metadataFilename}`);
        
    } else {
        console.log('\n❌ No animation_url found in metadata!');
    }
    
} catch (error) {
    console.error('\n❌ Error processing tokenURI:', error.message);
    
    // Try to help debug
    if (tokenURI.includes('"')) {
        console.log('\n💡 Hint: Make sure to properly escape quotes when passing the tokenURI');
    }
    
    // Save raw data for debugging
    fs.writeFileSync('debug_raw_uri.txt', tokenURI);
    console.log('\n🔍 Raw tokenURI saved to debug_raw_uri.txt for inspection');
}