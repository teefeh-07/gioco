# Artherealms - NFT Art Gaming Platform

Artherealms is a decentralized NFT Art Gaming Platform built on the Stacks blockchain using Clarity smart contracts. It allows artists to create, battle, and evolve their digital art creatures.

## Features

1. **NFT Minting**: Create unique digital art creatures as NFTs with randomized attributes.
2. **Artist Statistics**: Track and update artist performance and reputation.
3. **Exhibitions**: Start, vote for, and end art exhibitions with anti-spam voting protection.
4. **Battle System**: Challenge other creatures to battles with outcome-based rewards.
5. **Evolution System**: Evolve creatures by meeting battle and exhibition requirements.
6. **Admin Controls**: Contract owner can manage mint prices and transfer ownership.
7. **Anti-Fraud Protection**: Prevents double voting and self-battles.

## Smart Contract Functions

### Public Functions

#### Core Functions
1. `mint-art-creature`: Mint a new art creature NFT with randomized attributes.
2. `start-exhibition`: Start a new exhibition for a creature you own.
3. `vote-for-exhibition`: Vote for an ongoing exhibition (one vote per user).
4. `end-exhibition`: End an exhibition and update artist stats.

#### Battle System
5. `challenge-to-battle`: Challenge another creature to battle.
6. `resolve-battle`: Resolve a battle and determine the winner.

#### Evolution System
7. `evolve-creature`: Evolve your creature (requires 3+ battle wins and 2+ exhibitions).

#### Admin Functions
8. `set-mint-price`: Update the minting price (owner only).
9. `transfer-ownership`: Transfer contract ownership (owner only).

### Read-Only Functions

1. `get-creature-details`: Retrieve details of a specific creature.
2. `get-artist-stats`: Get statistics for a specific artist.
3. `get-exhibition-details`: Get details of a specific exhibition.
4. `get-battle-details`: Get details of a specific battle.
5. `has-voted`: Check if a user has voted for an exhibition.
6. `get-contract-info`: Get overall contract statistics and settings.

## Data Structures

1. `creature-attributes`: Stores attributes of each minted creature including evolution level and battle stats.
2. `artist-stats`: Keeps track of artist performance, reputation, and battle history.
3. `exhibitions`: Manages ongoing and completed exhibitions with voting data.
4. `exhibition-votes`: Tracks individual votes to prevent double voting.
5. `battles`: Records battle challenges, participants, and outcomes.

## Error Handling

The contract defines comprehensive error constants to handle various scenarios:

- `ERR-NOT-AUTHORIZED` (101): When an unauthorized action is attempted.
- `ERR-CREATURE-NOT-FOUND` (102): When a requested creature doesn't exist.
- `ERR-INSUFFICIENT-FUNDS` (103): For payment-related errors or unmet requirements.
- `ERR-EXHIBITION-ACTIVE` (104): When trying to end an active exhibition.
- `ERR-ALREADY-VOTED` (105): When trying to vote twice for the same exhibition.
- `ERR-EXHIBITION-NOT-FOUND` (106): When a requested exhibition doesn't exist.
- `ERR-BATTLE-NOT-FOUND` (107): When a requested battle doesn't exist.
- `ERR-BATTLE-ALREADY-COMPLETED` (108): When trying to resolve a completed battle.
- `ERR-CANNOT-BATTLE-SELF` (109): When trying to battle your own creature.
- `ERR-INVALID-INPUT` (110): For invalid input parameters.

## Getting Started

To interact with the Artherealms contract:

1. Deploy the contract to the Stacks blockchain.
2. Use a Stacks wallet (e.g., Hiro Wallet) to call the contract functions.
3. Mint your first art creature using the `mint-art-creature` function.
4. Start exhibitions, vote for your favorite artworks, and build your reputation as an artist!
5. Challenge other creatures to battles to earn victories and reputation.
6. Evolve your creatures by meeting battle and exhibition requirements.

## Game Mechanics

### Minting
- Cost: 0.1 STX (configurable by admin)
- Generates random attributes: art-power, creativity, rarity
- Each creature starts at evolution level 1

### Exhibitions
- Only creature owners can start exhibitions
- Users can vote once per exhibition
- Exhibitions have duration limits
- Successful exhibitions increase artist reputation

### Battles
- Challenge any other creature to battle
- Battle outcome determined by creature stats + randomness
- Winners gain battle victories and reputation
- Battle history is permanently recorded

### Evolution
- Requirements: 3+ battle wins AND 2+ exhibitions held
- Cost increases with evolution level (0.05 STX per level)
- Boosts creature stats: +10 art-power, +8 creativity, +5 rarity
- Maximum evolution level: 5

## Development

To work on this contract locally:

1. Install the [Clarinet](https://github.com/hirosystems/clarinet) development tool.
2. Clone this repository.
3. Run tests: `clarinet test`
4. Use Clarinet to test and deploy the contract.

## Testing

The contract includes comprehensive tests covering:
- NFT minting functionality
- Exhibition system with voting protection
- Battle system mechanics
- Evolution requirements and mechanics
- Admin functions and access control
- Error handling and edge cases

Run tests with: `clarinet test`

## Security Features

- **Anti-double voting**: Users can only vote once per exhibition
- **Ownership verification**: Only creature owners can start exhibitions or battles
- **Admin access control**: Only contract owner can modify settings
- **Input validation**: All functions validate input parameters
- **Battle fairness**: Outcomes use creature stats plus randomness
- **Evolution requirements**: Prevents easy stat boosting

## Recent Updates (v2.0)

- ✅ Added comprehensive battle system
- ✅ Implemented creature evolution mechanics
- ✅ Added anti-double voting protection
- ✅ Improved error handling and validation
- ✅ Added admin controls for contract management
- ✅ Separated exhibition and token ID counters
- ✅ Enhanced security and access controls
- ✅ Added comprehensive test suite
- ✅ Improved documentation and README




