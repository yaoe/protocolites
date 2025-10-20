// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";
import "./interfaces/IProtocolitesRenderer.sol";

/**
 * @title ProtocolitesRendererSimple
 * @notice Gas-efficient renderer with pre-defined ASCII variants
 */
contract ProtocolitesRendererSimple is Ownable, IProtocolitesRenderer {

    constructor() {
        _initializeOwner(msg.sender);
    }

    function renderScript() external pure returns (string memory) {
        return "";
    }

    function setRenderScript(string memory) external onlyOwner {}

    function tokenURI(uint256 tokenId, TokenData memory data) external pure returns (string memory) {
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadata(tokenId, data))));
    }

    function metadata(uint256 tokenId, TokenData memory data) public pure returns (string memory) {
        bool isKid = data.isKid;
        string memory color = getColor(data.dna);
        string memory ascii = getASCII(data.dna, isKid);

        // Minimal HTML - no external fonts, no complex CSS
        string memory html = string.concat(
            '<html><body style="margin:0;display:flex;align-items:center;justify-content:center;',
            'min-height:100vh;background:#fff;font-family:monospace">',
            '<pre style="font-size:', isKid ? '16' : '20', 'px;line-height:1;color:', color, '">',
            ascii,
            '</pre></body></html>'
        );

        string memory json = string.concat(
            '{"name":"Protocolite #', LibString.toString(tokenId),
            isKid ? ' (Child)",' : ' (Spreader)",',
            '"description":"On-chain ASCII creature",',
            '"animation_url":"data:text/html;base64,', Base64.encode(bytes(html)), '",',
            '"attributes":[{"trait_type":"Type","value":"', isKid ? 'Child' : 'Spreader',
            '"},{"trait_type":"DNA","value":"', LibString.toHexString(data.dna), '"}]}'
        );

        return json;
    }

    function getASCII(uint256 dna, bool isKid) internal pure returns (string memory) {
        uint256 variant = (dna >> 3) & 15; // 16 variants

        if (isKid) {
            // 16x16 kids - 16 variants
            if (variant == 0) return unicode"     ●●\n   ██████\n  ████████\n  ██ ◉◉ ██\n  ████████\n   ██████\n   ██  ██\n   ██  ██";
            if (variant == 1) return unicode"     ◉◉\n   ▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓\n  ▓▓ ● ● ▓▓\n  ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓\n   ▓▓  ▓▓\n   ▓▓  ▓▓";
            if (variant == 2) return unicode"     ○○\n   ▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒\n  ▒▒ ◎ ◎ ▒▒\n  ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒\n   ▒▒  ▒▒\n   ▒▒  ▒▒";
            if (variant == 3) return unicode"     ◎◎\n   ░░░░░░\n  ░░░░░░░░\n  ░░ ○ ○ ░░\n  ░░░░░░░░\n   ░░░░░░\n   ░░  ░░\n   ░░  ░░";
            if (variant == 4) return unicode"     ●\n   ██████\n  ████████\n  ██ ●● ██\n  ██▓▓▓▓██\n   ██████\n   ██  ██\n   ██  ██";
            if (variant == 5) return unicode"     ◉\n   ▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓\n  ▓▓ ◉◉ ▓▓\n  ▓▓████▓▓\n   ▓▓▓▓▓▓\n   ▓▓  ▓▓\n   ▓▓  ▓▓";
            if (variant == 6) return unicode"   ●●●●\n   ▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓\n  ▓▓ ○○ ▓▓\n  ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓\n   ▓▓  ▓▓\n   ▓▓  ▓▓";
            if (variant == 7) return unicode"   ○ ○\n   ▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒\n  ▒▒ ●● ▒▒\n  ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒\n   ▒▒  ▒▒\n   ▒▒  ▒▒";
            if (variant == 8) return unicode"     ★\n   ░░░░░░\n  ░░░░░░░░\n  ░░ ◎◎ ░░\n  ░░░░░░░░\n   ░░░░░░\n   ░░  ░░\n   ░░  ░░";
            if (variant == 9) return unicode"     ☆\n   ██████\n  ████████\n  ██ ○○ ██\n  ██████████\n   ██████\n   ██  ██\n   ██  ██";
            if (variant == 10) return unicode"     ●\n   ▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓\n  ▓▓ ◉◉ ▓▓\n  ▓▓▓~▓▓▓▓\n   ▓▓▓▓▓▓\n   ▓▓  ▓▓\n   ▓▓  ▓▓";
            if (variant == 11) return unicode"   ●●●\n   ▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒\n  ▒▒ ●● ▒▒\n  ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒\n   ▒▒  ▒▒\n   ▒▒  ▒▒";
            if (variant == 12) return unicode"     ◉\n   ░░░░░░\n  ░░░░░░░░\n  ░░ ◎◎ ░░\n  ░░-░░░░░\n   ░░░░░░\n   ░░  ░░\n   ░░  ░░";
            if (variant == 13) return unicode"   ───\n   ██████\n  ████████\n  ██ ●● ██\n  ██████████\n   ██████\n   ██  ██\n   ██  ██";
            if (variant == 14) return unicode"   ═══\n   ▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓\n  ▓▓ ◉◉ ▓▓\n  ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓\n   ▓▓  ▓▓\n   ▓▓  ▓▓";
            return unicode"   ▀▀▀\n   ░░░░░░\n  ░░░░░░░░\n  ░░ ○○ ░░\n  ░░░░░░░░\n   ░░░░░░\n   ░░  ░░\n   ░░  ░░";
        } else {
            // 24x24 spreaders - 16 variants
            if (variant == 0) return unicode"       ●●\n     ████████\n   ████████████\n  ██████████████\n  ████ ◉◉ ████\n  ██████████████\n   ████████████\n   ────██──██────\n     ██████████\n      ████  ████\n      ████  ████";
            if (variant == 1) return unicode"       ◉◉\n     ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓ ●● ▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n   ────▓▓──▓▓────\n     ▓▓▓▓▓▓▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓";
            if (variant == 2) return unicode"       ○○\n     ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒ ◎◎ ▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n   ────▒▒──▒▒────\n     ▒▒▒▒▒▒▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒";
            if (variant == 3) return unicode"       ◎◎\n     ░░░░░░░░\n   ░░░░░░░░░░░░\n  ░░░░░░░░░░░░░░\n  ░░░░ ○○ ░░░░\n  ░░░░░░░░░░░░░░\n   ░░░░░░░░░░░░\n   ────░░──░░────\n     ░░░░░░░░░░\n      ░░░░  ░░░░\n      ░░░░  ░░░░";
            if (variant == 4) return unicode"       ●\n     ████████\n   ████████████\n  ██████████████\n  ████ ●●● ████\n  ██████████████\n   ████████████\n   ════██══██════\n     ██████████\n      ████  ████\n      ████  ████";
            if (variant == 5) return unicode"     ◉◉◉\n     ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓ ◉◉ ▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n   ════▓▓══▓▓════\n     ▓▓▓▓▓▓▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓";
            if (variant == 6) return unicode"     ○○○\n     ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒ ●● ▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n   ────▒▒──▒▒────\n     ▒▒▒▒▒▒▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒";
            if (variant == 7) return unicode"     ★★★\n     ░░░░░░░░\n   ░░░░░░░░░░░░\n  ░░░░░░░░░░░░░░\n  ░░░░ ◎◎ ░░░░\n  ░░░░░░░░░░░░░░\n   ░░░░░░░░░░░░\n   ────░░──░░────\n     ░░░░░░░░░░\n      ░░░░  ░░░░\n      ░░░░  ░░░░";
            if (variant == 8) return unicode"       ●\n     ████████\n   ████████████\n  ██████████████\n  ████ ○○ ████\n  ██████~███████\n   ████████████\n   ────██──██────\n     ██████████\n      ████  ████\n      ████  ████";
            if (variant == 9) return unicode"     ───\n     ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓ ●● ▓▓▓▓\n  ▓▓▓▓▓~▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n   ────▓▓──▓▓────\n     ▓▓▓▓▓▓▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓";
            if (variant == 10) return unicode"     ═══\n     ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒ ◉◉ ▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n   ════▒▒══▒▒════\n     ▒▒▒▒▒▒▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒";
            if (variant == 11) return unicode"     ▀▀▀\n     ░░░░░░░░\n   ░░░░░░░░░░░░\n  ░░░░░░░░░░░░░░\n  ░░░░ ○○ ░░░░\n  ░░░░░░░░░░░░░░\n   ░░░░░░░░░░░░\n   ────░░──░░────\n     ░░░░░░░░░░\n      ░░░░  ░░░░\n      ░░░░  ░░░░";
            if (variant == 12) return unicode"       ☆\n     ████████\n   ████████████\n  ██████████████\n  ████ ●● ████\n  ██████████████\n   ████████████\n   ║║║║██══██║║║║\n     ██████████\n      ████  ████\n      ████  ████";
            if (variant == 13) return unicode"       ◉\n     ▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n  ▓▓▓▓ ◎◎ ▓▓▓▓\n  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓\n   ▓▓▓▓▓▓▓▓▓▓▓▓\n   ║║║║▓▓══▓▓║║║║\n     ▓▓▓▓▓▓▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓\n      ▓▓▓▓  ▓▓▓▓";
            if (variant == 14) return unicode"     ●●●\n     ▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n  ▒▒▒▒ ●● ▒▒▒▒\n  ▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n   ▒▒▒▒▒▒▒▒▒▒▒▒\n   ════▒▒══▒▒════\n     ▒▒▒▒▒▒▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒\n      ▒▒▒▒  ▒▒▒▒";
            return unicode"       ★\n     ░░░░░░░░\n   ░░░░░░░░░░░░\n  ░░░░░░░░░░░░░░\n  ░░░░ ◉◉ ░░░░\n  ░░░░░░░░░░░░░░\n   ░░░░░░░░░░░░\n   ════░░══░░════\n     ░░░░░░░░░░\n      ░░░░  ░░░░\n      ░░░░  ░░░░";
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
