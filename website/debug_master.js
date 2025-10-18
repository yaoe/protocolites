// Debug script for checking ProtocolitesMaster contract state
const ethers = require('ethers');

async function debug() {
    // Contract addresses
    const MASTER_ADDRESS = "YOUR_MASTER_ADDRESS"; // Replace with your master contract
    const TOKEN_ID = 1;
    
    // Simple ABI for the functions we need
    const abi = [
        "function totalSupply() view returns (uint256)",
        "function ownerOf(uint256) view returns (address)",
        "function infectionContracts(uint256) view returns (address)",
        "function getInfectionContract(uint256) view returns (address)",
        "function exists(uint256) view returns (bool)"
    ];
    
    const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
    const master = new ethers.Contract(MASTER_ADDRESS, abi, provider);
    
    console.log("🔍 Debugging ProtocolitesMaster...\n");
    
    try {
        // Check total supply
        const totalSupply = await master.totalSupply();
        console.log("Total Supply:", totalSupply.toString());
        
        // Check if token #1 exists
        const exists = await master.exists(TOKEN_ID);
        console.log("Token #1 exists:", exists);
        
        if (exists) {
            // Get owner
            const owner = await master.ownerOf(TOKEN_ID);
            console.log("Token #1 owner:", owner);
            
            // Get infection contract
            const infectionContract = await master.getInfectionContract(TOKEN_ID);
            console.log("Infection contract:", infectionContract);
            
            if (infectionContract === "0x0000000000000000000000000000000000000000") {
                console.log("\n⚠️  ISSUE FOUND: No infection contract deployed for token #1!");
                console.log("This means the spawn didn't complete properly.");
            }
        }
        
    } catch (error) {
        console.error("Error:", error.message);
    }
}

debug();