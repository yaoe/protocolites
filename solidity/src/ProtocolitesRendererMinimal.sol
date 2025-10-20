// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";

import "./interfaces/IProtocolitesRenderer.sol";

/**
 * @title ProtocolitesRendererMinimal
 * @notice Ultra-minimal SVG renderer for low gas usage
 * @dev Works with OpenSea's strict gas limits
 */
contract ProtocolitesRendererMinimal is Ownable, IProtocolitesRenderer {

    constructor() {
        _initializeOwner(msg.sender);
    }

    function renderScript() external pure returns (string memory) {
        return "";
    }

    function setRenderScript(string memory) external onlyOwner {
        // Not used in minimal renderer
    }

    function tokenURI(uint256 tokenId, TokenData memory data) external pure returns (string memory) {
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadata(tokenId, data))));
    }

    function metadata(uint256 tokenId, TokenData memory data) public pure returns (string memory) {
        bool isKid = data.isKid;

        // Get family color from DNA
        string memory color = getColor(data.dna);

        // Create minimal SVG
        string memory svg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">',
            '<rect width="400" height="400" fill="white"/>',
            '<text x="200" y="200" font-family="monospace" font-size="',
            isKid ? '60' : '80',
            '" fill="',
            color,
            '" text-anchor="middle" dominant-baseline="middle">',
            isKid ? '&#x1F476;' : '&#x1F47E;', // Baby or alien emoji
            '</text>',
            '<text x="200" y="300" font-family="monospace" font-size="16" fill="black" text-anchor="middle">#',
            LibString.toString(tokenId),
            '</text>',
            '</svg>'
        );

        string memory attributes = string.concat(
            '[{"trait_type":"Type","value":"',
            isKid ? "Child" : "Spreader",
            '"},{"trait_type":"DNA","value":"',
            LibString.toHexString(data.dna),
            '"}]'
        );

        string memory json = string.concat(
            '{"name":"Protocolite #',
            LibString.toString(tokenId),
            isKid ? " (Child)" : " (Spreader)",
            '","description":"On-chain generative NFT","image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '","attributes":',
            attributes,
            '}'
        );

        return json;
    }

    function getColor(uint256 dna) internal pure returns (string memory) {
        uint256 colorIndex = (dna >> 17) % 6;

        if (colorIndex == 0) return "#cc0000"; // red
        if (colorIndex == 1) return "#008800"; // green
        if (colorIndex == 2) return "#0044cc"; // blue
        if (colorIndex == 3) return "#cc9900"; // yellow
        if (colorIndex == 4) return "#8800cc"; // purple
        return "#0088aa"; // cyan
    }
}
