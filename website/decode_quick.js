// Quick decoder for the tokenURI from your test output
const uri = "data:application/json;base64,eyJuYW1lIjoiUHJvdG9jb2xpdGUgIzEgKFBhcmVudCkiLCJkZXNjcmlwdGlvbiI6IkZ1bGx5IG9uLWNoYWluIGdlbmVyYXRpdmUgY3JlYXR1cmVzIHRoYXQgY2FuIGJyZWVkIGtpZHMgb3Igc3Bhd24gbmV3IGNvbG9uaWVzLiIsImFuaW1hdGlvbl91cmwiOiJkYXRhOnRleHQvaHRtbDtiYXNlNjQsUENoaFJFOURWRmxRUlNCb2RHMXNQZ284YUdWaFpEND0iLCJhdHRyaWJ1dGVzIjpbeyJ0cmFpdF90eXBlIjoiVHlwZSIsInZhbHVlIjoiUGFyZW50In0seyJ0cmFpdF90eXBlIjoiU2l6ZSIsInZhbHVlIjoiMjR4MjQifSx7InRyYWl0X3R5cGUiOiJETkEiLCJ2YWx1ZSI6IjB4YTgzNDk2MmFlZDQ2MzU1ZTNmZTYwNTQ3OGIzOGI3ZDYxNDkyNTI1Y2ZkYzk4ZTJmNDY5MjAzNGNjNjZjOGRiMSJ9LHsidHJhaXRfdHlwZSI6IkJpcnRoIEJsb2NrIiwidmFsdWUiOjF9XX0=";

const fs = require('fs');

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
    
    console.log('\n=== HTML CONTENT ===');
    console.log(html);
    
    console.log('\n=== SAVING HTML ===');
    const filename = `test_protocolite.html`;
    fs.writeFileSync(filename, html);
    console.log(`Animation saved to: ${filename}`);
    console.log('Open this file in your browser to view the Protocolite!');
}