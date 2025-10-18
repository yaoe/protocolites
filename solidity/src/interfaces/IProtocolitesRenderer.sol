// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IProtocolitesRenderer {
    struct TokenData {
        uint256 dna;
        bool isKid;
        uint256 parentDna;
        address parentContract;
        uint256 birthBlock;
    }

    function tokenURI(uint256 tokenId, TokenData memory data) external view returns (string memory);

    function setRenderScript(string memory _script) external;

    function renderScript() external view returns (string memory);
}
