#!/usr/bin/env node

// Usage: node decode_and_view.js "<tokenURI_from_test>"
// This will decode the base64 and save the HTML file for viewing

const fs = require('fs');

function decodeTokenURI(uri) {
    try {
        // Remove the data:application/json;base64, prefix
        const base64 = uri.replace('data:application/json;base64,', '');
        
        // Decode base64 to JSON
        const json = JSON.parse(Buffer.from(base64, 'base64').toString('utf8'));
        
        console.log('=== TOKEN METADATA ===');
        console.log('Name:', json.name);
        console.log('Description:', json.description);
        console.log('Attributes:', JSON.stringify(json.attributes, null, 2));
        
        // Extract and decode animation_url
        if (json.animation_url) {
            const animationBase64 = json.animation_url.replace('data:text/html;base64,', '');
            const html = Buffer.from(animationBase64, 'base64').toString('utf8');
            
            console.log('\n=== SAVING HTML ===');
            const filename = `protocolite_${Date.now()}.html`;
            fs.writeFileSync(filename, html);
            console.log(`Animation saved to: ${filename}`);
            console.log('Open this file in your browser to view the Protocolite!');
            
            return filename;
        }
    } catch (error) {
        console.error('Error decoding URI:', error);
    }
}

// If called directly with URI argument
if (process.argv[2]) {
    decodeTokenURI(process.argv[2]);
} else {
    console.log('Usage: node decode_and_view.js "<tokenURI>"');
    console.log('Example: node decode_and_view.js "data:application/json;base64,eyJ..."');
}

module.exports = { decodeTokenURI };