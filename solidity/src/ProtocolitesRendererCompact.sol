// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";
import "./interfaces/IProtocolitesRenderer.sol";

/**
 * @title ProtocolitesRendererCompact
 * @notice Compact ASCII renderer optimized for low gas - no external HTML, pure SVG
 */
contract ProtocolitesRendererCompact is Ownable, IProtocolitesRenderer {

    constructor() {
        _initializeOwner(msg.sender);
    }

    function renderScript() external pure returns (string memory) {
        return "";
    }

    function setRenderScript(string memory) external onlyOwner {
        // Not used in compact renderer
    }

    function tokenURI(uint256 tokenId, TokenData memory data) external pure returns (string memory) {
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadata(tokenId, data))));
    }

    function metadata(uint256 tokenId, TokenData memory data) public pure returns (string memory) {
        bool isKid = data.isKid;
        string memory color = getColor(data.dna);

        // Generate minimal ASCII creature
        string memory ascii = generateASCII(data.dna, isKid);

        // Create compact SVG with ASCII
        string memory svg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">',
            '<rect fill="#fff" width="400" height="400"/>',
            '<text x="200" y="200" font-family="monospace" font-size="',
            isKid ? '18' : '22',
            '" fill="',
            color,
            '" text-anchor="middle" style="white-space:pre">',
            ascii,
            '</text></svg>'
        );

        string memory json = string.concat(
            '{"name":"Protocolite #',
            LibString.toString(tokenId),
            isKid ? " (Child)" : " (Spreader)",
            '","description":"On-chain ASCII creature",',
            '"image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '","attributes":[{"trait_type":"Type","value":"',
            isKid ? "Child" : "Spreader",
            '"},{"trait_type":"DNA","value":"',
            LibString.toHexString(data.dna),
            '"}]}'
        );

        return json;
    }

    function generateASCII(uint256 dna, bool isKid) internal pure returns (string memory) {
        // Ultra-simple ASCII creature based on DNA
        uint256 variant = (dna >> 3) & 3;

        if (isKid) {
            if (variant == 0) return unicode"  ●\n ███\n █ █";
            if (variant == 1) return unicode"  ◉\n ▓▓▓\n ▓ ▓";
            if (variant == 2) return unicode"  ○\n ▒▒▒\n ▒ ▒";
            return unicode"  ◎\n ░░░\n ░ ░";
        } else {
            if (variant == 0) return unicode"  ●●\n █████\n █   █\n ██ ██";
            if (variant == 1) return unicode"  ◉◉\n ▓▓▓▓▓\n ▓   ▓\n ▓▓ ▓▓";
            if (variant == 2) return unicode"  ○○\n ▒▒▒▒▒\n ▒   ▒\n ▒▒ ▒▒";
            return unicode"  ◎◎\n ░░░░░\n ░   ░\n ░░ ░░";
        }
    }

    function getColor(uint256 dna) internal pure returns (string memory) {
        uint256 colorIndex = (dna >> 17) % 6;
        if (colorIndex == 0) return "#c00";
        if (colorIndex == 1) return "#080";
        if (colorIndex == 2) return "#04c";
        if (colorIndex == 3) return "#c90";
        if (colorIndex == 4) return "#80c";
        return "#08a";
    }
}
