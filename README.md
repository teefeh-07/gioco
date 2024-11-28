# Artherealms - NFT Art Gaming Platform

Artherealms is a decentralized NFT Art Gaming Platform built on the Stacks blockchain using Clarity smart contracts. It allows artists to create, battle, and evolve their digital art creatures.

## Features

1. **NFT Minting**: Create unique digital art creatures as NFTs.
2. **Artist Statistics**: Track and update artist performance and reputation.
3. **Exhibitions**: Start, vote for, and end art exhibitions.
4. **Random Attribute Generation**: Generate unique attributes for each creature.

## Smart Contract Functions

### Public Functions

1. `mint-art-creature`: Mint a new art creature NFT.
2. `start-exhibition`: Start a new exhibition for a creature.
3. `vote-for-exhibition`: Vote for an ongoing exhibition.
4. `end-exhibition`: End an exhibition and update artist stats.

### Read-Only Functions

1. `get-creature-details`: Retrieve details of a specific creature.
2. `get-artist-stats`: Get statistics for a specific artist.

## Data Structures

1. `creature-attributes`: Stores attributes of each minted creature.
2. `artist-stats`: Keeps track of artist performance and reputation.
3. `exhibitions`: Manages ongoing exhibitions.

## Error Handling

The contract defines several error constants to handle various scenarios:

- `ERR-NOT-AUTHORIZED`: When an unauthorized action is attempted.
- `ERR-CREATURE-NOT-FOUND`: When a requested creature doesn't exist.
- `ERR-INSUFFICIENT-FUNDS`: For payment-related errors.
- `ERR-EXHIBITION-ACTIVE`: When trying to end an active exhibition.

## Getting Started

To interact with the Artherealms contract:

1. Deploy the contract to the Stacks blockchain.
2. Use a Stacks wallet (e.g., Hiro Wallet) to call the contract functions.
3. Mint your first art creature using the `mint-art-creature` function.
4. Start exhibitions, vote for your favorite artworks, and build your reputation as an artist!

## Development

To work on this contract locally:

1. Install the [Clarinet](https://github.com/hirosystems/clarinet) development tool.
2. Clone this repository.
3. Use Clarinet to test and deploy the contract.




