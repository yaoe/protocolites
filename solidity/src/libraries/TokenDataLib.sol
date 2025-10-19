// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IProtocolitesRenderer.sol";

library TokenDataLib {
    /**
     * @dev Creates a new TokenData struct for parent NFTs
     * @param dna The DNA of the parent NFT
     * @param birthBlock The block number when the NFT was born
     * @return TokenData struct configured for a parent NFT
     */
    function createParentData(uint256 dna, uint256 birthBlock)
        internal
        pure
        returns (IProtocolitesRenderer.TokenData memory)
    {
        return IProtocolitesRenderer.TokenData({
            dna: dna,
            isKid: false,
            parentDna: 0,
            parentContract: address(0),
            birthBlock: birthBlock
        });
    }

    /**
     * @dev Creates a new TokenData struct for kid/infection NFTs
     * @param dna The DNA of the kid NFT
     * @param parentDna The DNA of the parent NFT
     * @param parentContract The address of the parent contract
     * @param birthBlock The block number when the NFT was born
     * @return TokenData struct configured for a kid NFT
     */
    function createKidData(uint256 dna, uint256 parentDna, address parentContract, uint256 birthBlock)
        internal
        pure
        returns (IProtocolitesRenderer.TokenData memory)
    {
        return IProtocolitesRenderer.TokenData({
            dna: dna,
            isKid: true,
            parentDna: parentDna,
            parentContract: parentContract,
            birthBlock: birthBlock
        });
    }

    /**
     * @dev Checks if the TokenData represents a parent NFT
     * @param data The TokenData to check
     * @return True if it's a parent NFT, false if it's a kid
     */
    function isParent(IProtocolitesRenderer.TokenData memory data) internal pure returns (bool) {
        return !data.isKid;
    }

    /**
     * @dev Checks if the TokenData represents a kid/infection NFT
     * @param data The TokenData to check
     * @return True if it's a kid NFT, false if it's a parent
     */
    function isKid(IProtocolitesRenderer.TokenData memory data) internal pure returns (bool) {
        return data.isKid;
    }
}
