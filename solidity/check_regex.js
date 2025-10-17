// Test if the regex works correctly
const testString = 'const parts=color.match(/\\d+/g);';
console.log('Test string:', testString);

// Check if it needs double escaping in Solidity
const solidityString = 'const parts=color.match(/\\\\d+/g);';
console.log('Solidity string:', solidityString);

// Test the actual regex
const color = "hsl(123, 45%, 67%)";
const parts1 = color.match(/\d+/g);
console.log('Direct regex result:', parts1);

// Test with escaped version
try {
    const regex = new RegExp('\\d+', 'g');
    const parts2 = color.match(regex);
    console.log('Escaped regex result:', parts2);
} catch (e) {
    console.log('Error:', e);
}