// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title NFT
 * NFT - a contract for non-fungible tokens.
 */
contract NFT is ERC721Tradable {
    constructor()
        ERC721Tradable("<nameHere>", "<symbolHere>", "<royaltyFeeHere>", "<OpenSeaProxyRegistryAddress>", "<LooksRareTransferManagerERC721Address>")
    {}

    /** IPFS URI of form ipfs://<contractCID> is strongly encouraged */
    function contractURI() public pure returns (string memory) {
        return "<contractUrlHere>";
    }
}
