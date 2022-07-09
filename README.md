## IPFS Batch Mint - Starter ERC721 contract

What's included:

### Sample ERC721 Contract

This includes a very simple sample ERC721 contract for the purposes of demonstrating integration with the [OpenSea](https://opensea.io) marketplace.

Additionally, this contract whitelists the proxy accounts of OpenSea users so that they are automatically able to trade the ERC721 item on OpenSea (without having to pay gas for an additional approval). On OpenSea, each user has a "proxy" account that they control, and is ultimately called by the exchange contracts to trade their items. (Note that this addition does not mean that OpenSea itself has access to the items, simply that the users can list them more easily if they wish to do so)

The sample contract `NFT.sol` has added functionality of batch minting tokens with IPFS metadata. It also whitelists the transfer manager address for integration on LooksRare.

Each batch of tokens will share the same IPFS parent directory. **See Minting for more details**

This allows the owner of the contract to mint new NFTs while preserving the immutability of the token metadata on IPFS for existing tokens.

## Requirements

### Node version

Either make sure you're running a version of node compliant with the `engines` requirement in `package.json`, or install Node Version Manager [`nvm`](https://github.com/creationix/nvm) and run `nvm use` to use the correct version of node.

## Installation

Run

```bash
yarn --ignore-engines
```

If you run into an error while building the dependencies and you're on a Mac, run the code below, remove your `node_modules` folder, and do a fresh `yarn install`:

```bash
xcode-select --install # Install Command Line Tools if you haven't already.
sudo xcode-select --switch /Library/Developer/CommandLineTools # Enable command line tools
sudo npm explore npm -g -- npm install node-gyp@latest # Update node-gyp
```

## Deploying

Deploy the flattened contract `flattened/NFT.sol`.

`<nameHere>`, `<symbolHere>`, `<royaltyFeeHere>`, `<OpenSeaProxyRegistryAddress>`, `<LooksRareTransferManagerERC721Address>` and `<contractUrlHere>` must be replaced with the appropriate values before compiling and deploying the contract.

It is **highly recommended** but not required for `contractURI` to return an IPFS URL of form of form `ipfs://<contractCID>`.

## Minting tokens.

The owner of the contract can mint a range of new tokens through `mintBatchTo`.

`mintBatchTo` takes four (4) arguments `address _to, uint256 _startTokenId, uint256 _endTokenId, string memory _baseTokenCID`.

As in the original OpenSea starter contract, `_to` is the address of the future owner of the token.

`_startTokenId` and `_endTokenId` are the bounds of the range of tokens to mint. These bounds are inclusive. All batches must be consecutive: if `_endTokenId` of `Batch A` is `x`, then it **MUST** hold that `_startTokenId` of `Batch A+1` is `x+1`. This property ensures that all tokenIds are contiguous. The first tokenId to be minted will be `1` since the `_endTokenId` of `Batch 0` before any tokens are minted is defined to be `0`.

`_baseTokenCID` is the CID of the IPFS parent folder containing the token metadata for that batch. This is **only the CID** and not the full IPFS URL `ipfs://<CID>`. Make sure this CID is correct before calling the function because it cannot be changed later!

For example, if `Batch 1` is the first batch of tokens to be minted and has `500` tokens, the contract call should be

```
mintBatchTo(<addressHere>, 1, 500, <cidHere>)
```

`ipfs://<cidHere>/<tokenId>` should be a valid IPFS URL containing valid metadata for `tokenId` in the range 1 to 500 inclusive.

It is **highly recommended** that the contract owner mint tokens in a few larger batches rather than many smaller batches to optimize for gas fees and utilization of internal structures.

# Requirements

### Node version

Either make sure you're running a version of node compliant with the `engines` requirement in `package.json`, or install Node Version Manager [`nvm`](https://github.com/creationix/nvm) and run `nvm use` to use the correct version of node.

## Installation

Run

```bash
yarn --ignore-engines
```

### Viewing your items on OpenSea

OpenSea will automatically pick up transfers on your contract. You can visit an asset by going to `https://opensea.io/assets/CONTRACT_ADDRESS/TOKEN_ID`.

To load all your metadata on your items at once, visit [https://opensea.io/get-listed](https://opensea.io/get-listed) and enter your address to load the metadata into OpenSea! You can even do this for the Rinkeby test network if you deployed there, by going to [https://rinkeby.opensea.io/get-listed](https://rinkeby.opensea.io/get-listed).
