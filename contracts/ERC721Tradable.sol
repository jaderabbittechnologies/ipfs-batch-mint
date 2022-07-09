// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "./ContentMixin.sol";
import {EIP712Base} from "./EIP712Base.sol";

/**
 * @title ERC721Tradable
 * ERC721Tradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
abstract contract ERC721Tradable is ERC721, ContextMixin, EIP712Base, Ownable, IERC2981 {
    uint256 royaltyFee;

    /**
     * The CIDs for off-chain token metadata on IPFS.
     * Each batch of minted tokens has exactly one (1) IPFS CID used to construct the tokenURI for all tokens in that batch.
     * Keys are the last valid tokenId in each minted batch.
     */
    mapping(uint256 => string) public cids;

    /**
     * An array of the last tokenId for each minted batch.
     * The last element of endTokenIds is the number of total tokens minted.
     * endTokenIds[0] = 0 upon contract construction
     */
    uint256[] public endTokenIds;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _royaltyFee,
        address _openseaProxyRegistryAddress,
        address _looksrareTransferManagerAddress
    ) ERC721(_name, _symbol) {
        require(_royaltyFee <= 10000, "ERC2981 Royalties: Too high");
        royaltyFee = _royaltyFee;
        _initializeEIP712(_name);

        /**
         * endTokenIds has first element 0 for contract functionality 
         * The first element does not have a corresponding key in cids.
         */

        endTokenIds.push(0);
        setApprovalForAll(_openseaProxyRegistryAddress, true);
        setApprovalForAll(_looksrareTransferManagerAddress, true);
    }

    /**
     * @dev Mint tokens _startTokenId <= _tokenId <= _endTokenId to an address with a tokenURI.
     * @dev tokenURI must be of form ipfs://<baseTokenCID>/<tokenId>
     * @dev Ensure that the CID is correct at function call since it cannot be modified later!
     * @dev This function should be called with a large batch size as few times as possible to reduce amortized gas cost per minted token.
     * @param _to address of the future owner of the token
     * @param _startTokenId first tokenId of batch (inclusive)
     * @param _endTokenId last tokenId of batch (inclusive)
     * @param _baseTokenCID CID of the IPFS folder containing batch token metadata
     */
    function mintBatchTo(
        address _to,
        uint256 _startTokenId,
        uint256 _endTokenId,
        string memory _baseTokenCID
    ) public onlyOwner {
        require(_startTokenId == endTokenIds[endTokenIds.length - 1] + 1, "tokenIds must be consecutive");
        require(_startTokenId <= _endTokenId, "tokenIds must be increasing");

        for (uint256 _tokenId = _startTokenId; _tokenId <= _endTokenId; ++_tokenId) {
            _safeMint(_to, _tokenId);
        }

        endTokenIds.push(_endTokenId);
        cids[_endTokenId] = _baseTokenCID;
    }

    /**
     *  @dev Returns the total tokens minted so far.
     */
    function totalSupply() public view returns (uint256) {
        return endTokenIds[endTokenIds.length - 1];
    }

    function baseTokenCID(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // i initialized at 1 since tokenId > 0
        for (uint256 i = 1; i < endTokenIds.length; ++i) {
            if (tokenId <= endTokenIds[i]) {
                return cids[endTokenIds[i]];
            }
        }
        return "";
    }

    /**
     * @dev tokenURI of form ipfs://<baseTokenCID>/<tokenId>
     * It is assumed that all tokens in a batch have metadata files tokenId stored in a IPFS folder with CID baseTokenCID
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        return string(abi.encodePacked("ipfs://", baseTokenCID(_tokenId), "/", Strings.toString(_tokenId)));
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender() internal view override returns (address sender) {
        return ContextMixin.msgSender();
    }

    /**
     * ERC2981 Royalty Fee
     * Sends Royalties to current Contract Owner
     */
    function royaltyInfo(uint256, uint256 value) external view override(IERC2981) returns (address receiver, uint256 royaltyAmount) {
        receiver = owner();
        royaltyAmount = (value * royaltyFee) / 10000;
    }

        /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

}
