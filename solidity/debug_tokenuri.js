// Get tokenURI and decode it
const tokenURI = process.argv[2];

if (!tokenURI) {
    console.log("Usage: node debug_tokenuri.js <tokenURI>");
    process.exit(1);
}

try {
    // Remove data:application/json;base64,
    const base64Data = tokenURI.replace('data:application/json;base64,', '');
    const jsonStr = Buffer.from(base64Data, 'base64').toString();
    const json = JSON.parse(jsonStr);
    
    console.log("=== METADATA ===");
    console.log("Name:", json.name);
    console.log("Attributes:", json.attributes);
    
    if (json.animation_url) {
        // Decode the HTML
        const htmlBase64 = json.animation_url.replace('data:text/html;base64,', '');
        const html = Buffer.from(htmlBase64, 'base64').toString();
        
        console.log("\n=== HTML LENGTH ===");
        console.log(html.length, "characters");
        
        // Save to file
        require('fs').writeFileSync('debug_output.html', html);
        console.log("\nSaved to debug_output.html");
        
        // Check for common issues
        if (html.includes('\\\\')) {
            console.log("\nWARNING: Found escaped backslashes in HTML");
        }
        
        // Show a preview
        console.log("\n=== HTML PREVIEW (first 500 chars) ===");
        console.log(html.substring(0, 500));
    }
} catch (e) {
    console.error("Error:", e.message);
    console.log("Raw URI:", tokenURI);
}