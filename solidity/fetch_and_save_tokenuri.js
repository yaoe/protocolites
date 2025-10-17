const { ethers } = require('ethers');
const fs = require('fs');

const MASTER_ADDRESS = '0x8a94e7c81a4982a80405b5aead52155208b40d18';
const RPC_URL = 'https://rpc.sepolia.org';

async function fetchAndSave() {
    try {
        console.log('Connecting to Sepolia...');
        const provider = new ethers.providers.JsonRpcProvider(RPC_URL);

        console.log('Creating contract instance...');
        const contract = new ethers.Contract(
            MASTER_ADDRESS,
            ['function tokenURI(uint256) view returns (string)'],
            provider
        );

        console.log('Fetching tokenURI for token #1...');
        const tokenURI = await contract.tokenURI(1);

        console.log('Decoding metadata...');
        const base64 = tokenURI.split(',')[1];
        const json = Buffer.from(base64, 'base64').toString();
        const metadata = JSON.parse(json);

        console.log('Metadata name:', metadata.name);
        console.log('Metadata description:', metadata.description);

        console.log('\nDecoding animation HTML...');
        const htmlBase64 = metadata.animation_url.split(',')[1];
        const html = Buffer.from(htmlBase64, 'base64').toString();

        // Check renderer type
        const isASCII = html.includes('ascii-display') || html.includes('const grid=Array(size)');
        const isPixelated = html.includes('canvas');

        console.log('\n==== RENDERER TYPE ====');
        if (isASCII) {
            console.log('✓✓✓ ASCII RENDERER DETECTED ✓✓✓');
        } else if (isPixelated) {
            console.log('✗✗✗ PIXELATED RENDERER (OLD) ✗✗✗');
        } else {
            console.log('??? UNKNOWN RENDERER ???');
        }

        console.log('\nHTML length:', html.length, 'characters');
        console.log('\nFirst 500 characters of HTML:');
        console.log('─'.repeat(80));
        console.log(html.substring(0, 500));
        console.log('─'.repeat(80));

        // Save to file
        const outputFile = 'token1_render.html';
        fs.writeFileSync(outputFile, html);
        console.log(`\n✓ Saved HTML to: ${outputFile}`);
        console.log('\nOpen it with: open token1_render.html');

    } catch (error) {
        console.error('Error:', error.message);
        console.error(error);
    }
}

fetchAndSave();
