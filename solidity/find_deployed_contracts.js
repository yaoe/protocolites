// Find deployed contract addresses from deployment
const fs = require('fs');

// Your deployment transaction details from the log
console.log('🔍 DEPLOYMENT ANALYSIS');
console.log('======================');

console.log('From your deployment log:');
console.log('✅ ProtocolitesRender deployed at: 0x617E088BB8D7aa11188d7De47aED62A2bE64a409');
console.log('✅ ProtocoliteFactory deployed at: 0x1558eA09092bAB5E7C46e15AE9e2215B30e39595');
console.log('✅ Protocolites deployed at: 0xb0D18E8b25B6120765815687358E9C0cAa0eD839');

console.log('\nThe mint transaction succeeded:');
console.log('Transaction Hash: 0xe1e04ed36fed288b0f27488bed76f9c416b4177fa4ac97d1e46e934eabfc8413');
console.log('Gas Used: 22,080');
console.log('Status: Success');

console.log('\n📋 MANUAL TESTING COMMANDS:');
console.log('===========================');

const contracts = {
    'PROTOCOLITES_ADDRESS': '0xb0D18E8b25B6120765815687358E9C0cAa0eD839',
    'RENDERER_ADDRESS': '0x617E088BB8D7aa11188d7De47aED62A2bE64a409',
    'FACTORY_ADDRESS': '0x1558eA09092bAB5E7C46e15AE9e2215B30e39595'
};

console.log('\n1. Check if contracts have code:');
Object.entries(contracts).forEach(([name, addr]) => {
    console.log(`forge script -f $RPC_URL --code ${addr} | wc -l`);
});

console.log('\n2. Check total supply:');
console.log(`forge script -f $RPC_URL -c "${contracts.PROTOCOLITES_ADDRESS}" "totalSupply()(uint256)"`);

console.log('\n3. Get tokenURI for token #1:');
console.log(`forge script -f $RPC_URL -c "${contracts.PROTOCOLITES_ADDRESS}" "tokenURI(uint256)" 1`);

console.log('\n4. Try minting another:');
console.log(`forge script -f $RPC_URL -c "${contracts.PROTOCOLITES_ADDRESS}" --private-key $PRIVATE_KEY "mint(address)" YOUR_ADDRESS`);

console.log('\n💡 ALTERNATIVE: Use web3 tools');
console.log('1. Visit your network block explorer');
console.log('2. Search for transaction: 0xe1e04ed36fed288b0f27488bed76f9c416b4177fa4ac97d1e46e934eabfc8413');
console.log('3. Check "Internal Transactions" to see actual deployed addresses');

console.log('\n🌐 If you deployed to Sepolia:');
console.log('https://sepolia.etherscan.io/tx/0xe1e04ed36fed288b0f27488bed76f9c416b4177fa4ac97d1e46e934eabfc8413');