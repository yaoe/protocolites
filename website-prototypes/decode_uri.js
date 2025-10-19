// decode_uri.js - Helper to decode tokenURI and extract animation

// Example tokenURI from contract (replace with actual)
const tokenURI = "data:application/json;base64,eyJuYW1lIjoiUHJvdG9jb2xpdGUgIzEgKFBhcmVudCkiLCJkZXNjcmlwdGlvbiI6IkZ1bGx5IG9uLWNoYWluIGdlbmVyYXRpdmUgY3JlYXR1cmVzIHRoYXQgY2FuIGJyZWVkIGtpZHMgb3Igc3Bhd24gbmV3IGNvbG9uaWVzLiIsImFuaW1hdGlvbl91cmwiOiJkYXRhOnRleHQvaHRtbDtiYXNlNjQsLi4uIiwiYXR0cmlidXRlcyI6W3sidHJhaXRfdHlwZSI6IlR5cGUiLCJ2YWx1ZSI6IlBhcmVudCJ9XX0=";

function decodeTokenURI(uri) {
    // Remove the data:application/json;base64, prefix
    const base64 = uri.replace('data:application/json;base64,', '');
    
    // Decode base64 to JSON
    const json = JSON.parse(atob(base64));
    
    console.log('Token Metadata:', json);
    
    // Extract and decode animation_url
    if (json.animation_url) {
        const animationBase64 = json.animation_url.replace('data:text/html;base64,', '');
        const html = atob(animationBase64);
        
        console.log('\nAnimation HTML:');
        console.log(html);
        
        // Save to file
        const fs = require('fs');
        fs.writeFileSync('protocolite_animation.html', html);
        console.log('\nAnimation saved to protocolite_animation.html');
    }
}

// If running in Node.js
if (typeof process !== 'undefined' && process.argv[2]) {
    decodeTokenURI(process.argv[2]);
} else {
    console.log('Usage: node decode_uri.js <tokenURI>');
    console.log('Or paste a tokenURI in the tokenURI variable above');
}