;; Artherealms - An NFT Art Gaming Platform
;; Where artists can create, battle, and evolve their digital art creatures

;; Define NFT token
(define-non-fungible-token artherealms-creature uint)

;; Data Maps and Variables
(define-data-var last-token-id uint u0)
(define-data-var last-exhibition-id uint u0)
(define-data-var mint-price uint u100000000) ;; Set in microSTX (0.1 STX)
(define-data-var contract-owner principal tx-sender)

;; Creature Attributes
(define-map creature-attributes
    uint
    {
        creator: principal,
        art-power: uint,
        creativity: uint,
        rarity: uint,
        evolution-level: uint,
        creation-time: uint,
        art-style: (string-ascii 20),
        battles-won: uint,
        exhibitions-held: uint
    }
)

;; Artist Stats
(define-map artist-stats
    principal
    {
        total-creatures: uint,
        exhibition-score: uint,
        reputation: uint,
        total-battles: uint
    }
)

;; Exhibition Details
(define-map exhibitions
    uint
    {
        curator: principal,
        creature-id: uint,
        start-time: uint,
        duration: uint,
        votes: uint,
        active: bool
    }
)

;; Voting tracking to prevent double voting
(define-map exhibition-votes
    { exhibition-id: uint, voter: principal }
    bool
)

;; Battle system
(define-map battles
    uint
    {
        challenger: principal,
        defender: principal,
        challenger-creature: uint,
        defender-creature: uint,
        winner: (optional principal),
        battle-time: uint,
        completed: bool
    }
)

(define-data-var last-battle-id uint u0)

;; Error Constants
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-CREATURE-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-EXHIBITION-ACTIVE (err u104))
(define-constant ERR-ALREADY-VOTED (err u105))
(define-constant ERR-EXHIBITION-NOT-FOUND (err u106))
(define-constant ERR-BATTLE-NOT-FOUND (err u107))
(define-constant ERR-BATTLE-ALREADY-COMPLETED (err u108))
(define-constant ERR-CANNOT-BATTLE-SELF (err u109))
(define-constant ERR-INVALID-INPUT (err u110))

;; Random Helper Functions
(define-private (get-random-uint (max uint))
    (let 
        (
            (block-hash (unwrap! (get-block-info? burnchain-header-hash (- block-height u1)) u0))
        )
        (mod (buff-to-uint-le block-hash) max)
    )
)

;; Fixed buffer to uint conversion with proper byte handling
(define-private (buff-to-uint-le (bytes (buff 32)))
    (let
        (
            (byte0 (unwrap-panic (element-at bytes u0)))
            (byte1 (unwrap-panic (element-at bytes u1)))
            (byte2 (unwrap-panic (element-at bytes u2)))
            (byte3 (unwrap-panic (element-at bytes u3)))
        )
        (+
            (buff-to-uint byte0)
            (* (buff-to-uint byte1) u256)
            (* (buff-to-uint byte2) u65536)
            (* (buff-to-uint byte3) u16777216)
        )
    )
)

;; Helper function to convert a single byte buffer to uint
(define-private (buff-to-uint (byte (buff 1)))
    (unwrap-panic (index-of BUFF_TO_BYTE byte))
)

;; Constant for byte conversion
(define-constant BUFF_TO_BYTE (list 
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

;; Random attribute generators
(define-private (generate-art-power)
    (+ u1 (get-random-uint u100))
)

(define-private (generate-creativity)
    (+ u1 (get-random-uint u80))
)

(define-private (generate-rarity)
    (+ u1 (get-random-uint u1000))
)

;; Admin functions
(define-private (is-contract-owner)
    (is-eq tx-sender (var-get contract-owner))
)

(define-public (set-mint-price (new-price uint))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (asserts! (> new-price u0) ERR-INVALID-INPUT)
        (var-set mint-price new-price)
        (ok new-price)
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
        (var-set contract-owner new-owner)
        (ok new-owner)
    )
)

;; Update artist statistics
(define-private (update-artist-stats (artist principal))
    (let
        (
            (current-stats (default-to
                {
                    total-creatures: u0,
                    exhibition-score: u0,
                    reputation: u100,
                    total-battles: u0
                }
                (map-get? artist-stats artist)
            ))
            (updated-stats (merge current-stats {
                total-creatures: (+ (get total-creatures current-stats) u1)
            }))
        )
        (map-set artist-stats artist updated-stats)
        updated-stats
    )
)

;; Mint new art creature
(define-public (mint-art-creature (art-style (string-ascii 20)))
    (let
        (
            (new-id (+ (var-get last-token-id) u1))
            (creator tx-sender)
        )
        ;; Input validation
        (asserts! (> (len art-style) u0) ERR-INVALID-INPUT)

        ;; Check payment
        (try! (stx-transfer? (var-get mint-price) tx-sender (as-contract tx-sender)))

        ;; Mint NFT
        (try! (nft-mint? artherealms-creature new-id creator))

        ;; Set initial attributes
        (map-set creature-attributes new-id
            {
                creator: creator,
                art-power: (generate-art-power),
                creativity: (generate-creativity),
                rarity: (generate-rarity),
                evolution-level: u1,
                creation-time: block-height,
                art-style: art-style,
                battles-won: u0,
                exhibitions-held: u0
            }
        )

        ;; Update last token id
        (var-set last-token-id new-id)

        ;; Update artist stats
        (update-artist-stats creator)

        (ok new-id)
    )
)

;; Get creature details
(define-read-only (get-creature-details (creature-id uint))
    (match (map-get? creature-attributes creature-id)
        creature-info (ok creature-info)
        (err ERR-CREATURE-NOT-FOUND)
    )
)

;; Get artist stats
(define-read-only (get-artist-stats (artist principal))
    (match (map-get? artist-stats artist)
        artist-info (ok artist-info)
        (err ERR-NOT-AUTHORIZED)
    )
)

;; Start an exhibition
(define-public (start-exhibition (creature-id uint) (duration uint))
    (let
        (
            (curator tx-sender)
            (new-exhibition-id (+ (var-get last-exhibition-id) u1))
        )
        ;; Input validation
        (asserts! (> duration u0) ERR-INVALID-INPUT)

        ;; Check if the curator owns the creature
        (asserts! (is-eq (unwrap! (nft-get-owner? artherealms-creature creature-id) ERR-CREATURE-NOT-FOUND) curator)
            ERR-NOT-AUTHORIZED)

        ;; Create the exhibition
        (map-set exhibitions new-exhibition-id
            {
                curator: curator,
                creature-id: creature-id,
                start-time: block-height,
                duration: duration,
                votes: u0,
                active: true
            }
        )

        ;; Update exhibition counter
        (var-set last-exhibition-id new-exhibition-id)

        ;; Update the creature's exhibition count
        (match (map-get? creature-attributes creature-id)
            creature-info
            (begin
                (map-set creature-attributes creature-id
                    (merge creature-info { exhibitions-held: (+ (get exhibitions-held creature-info) u1) }))
                (ok new-exhibition-id)
            )
            ERR-CREATURE-NOT-FOUND
        )
    )
)

;; Vote for an exhibition
(define-public (vote-for-exhibition (exhibition-id uint))
    (let
        (
            (voter tx-sender)
            (vote-key { exhibition-id: exhibition-id, voter: voter })
        )
        ;; Check if user already voted
        (asserts! (is-none (map-get? exhibition-votes vote-key)) ERR-ALREADY-VOTED)

        (match (map-get? exhibitions exhibition-id)
            exhibition
            (let
                (
                    (updated-votes (+ (get votes exhibition) u1))
                    (start-time (get start-time exhibition))
                    (duration (get duration exhibition))
                )
                ;; Check if exhibition is still active
                (asserts! (get active exhibition) ERR-EXHIBITION-ACTIVE)
                (asserts! (< block-height (+ start-time duration)) ERR-EXHIBITION-ACTIVE)

                ;; Record the vote
                (map-set exhibition-votes vote-key true)

                ;; Update exhibition votes
                (map-set exhibitions exhibition-id (merge exhibition { votes: updated-votes }))
                (ok updated-votes)
            )
            ERR-EXHIBITION-NOT-FOUND
        )
    )
)

;; End an exhibition
(define-public (end-exhibition (exhibition-id uint))
    (match (map-get? exhibitions exhibition-id)
        exhibition
        (let
            (
                (curator (get curator exhibition))
                (creature-id (get creature-id exhibition))
                (start-time (get start-time exhibition))
                (duration (get duration exhibition))
                (votes (get votes exhibition))
            )
            ;; Check if the exhibition has ended
            (asserts! (>= block-height (+ start-time duration)) ERR-EXHIBITION-ACTIVE)
            (asserts! (get active exhibition) ERR-EXHIBITION-ACTIVE)

            ;; Update artist stats
            (match (map-get? artist-stats curator)
                artist-info
                (begin
                    (map-set artist-stats curator
                        (merge artist-info {
                            exhibition-score: (+ (get exhibition-score artist-info) votes),
                            reputation: (+ (get reputation artist-info) u10)
                        }))
                    ;; Mark exhibition as inactive instead of deleting
                    (map-set exhibitions exhibition-id (merge exhibition { active: false }))
                    (ok votes)
                )
                ERR-NOT-AUTHORIZED
            )
        )
        ERR-EXHIBITION-NOT-FOUND
    )
)

;; Battle System Functions

;; Challenge another creature to battle
(define-public (challenge-to-battle (challenger-creature-id uint) (defender-creature-id uint))
    (let
        (
            (challenger tx-sender)
            (new-battle-id (+ (var-get last-battle-id) u1))
        )
        ;; Input validation
        (asserts! (not (is-eq challenger-creature-id defender-creature-id)) ERR-CANNOT-BATTLE-SELF)

        ;; Check if challenger owns the creature
        (asserts! (is-eq (unwrap! (nft-get-owner? artherealms-creature challenger-creature-id) ERR-CREATURE-NOT-FOUND) challenger)
            ERR-NOT-AUTHORIZED)

        ;; Get defender info
        (let
            (
                (defender (unwrap! (nft-get-owner? artherealms-creature defender-creature-id) ERR-CREATURE-NOT-FOUND))
            )
            ;; Cannot battle yourself
            (asserts! (not (is-eq challenger defender)) ERR-CANNOT-BATTLE-SELF)

            ;; Create battle
            (map-set battles new-battle-id
                {
                    challenger: challenger,
                    defender: defender,
                    challenger-creature: challenger-creature-id,
                    defender-creature: defender-creature-id,
                    winner: none,
                    battle-time: block-height,
                    completed: false
                }
            )

            ;; Update battle counter
            (var-set last-battle-id new-battle-id)

            (ok new-battle-id)
        )
    )
)

;; Resolve battle (can be called by either participant)
(define-public (resolve-battle (battle-id uint))
    (match (map-get? battles battle-id)
        battle
        (let
            (
                (challenger (get challenger battle))
                (defender (get defender battle))
                (challenger-creature (get challenger-creature battle))
                (defender-creature (get defender-creature battle))
            )
            ;; Check if battle is already completed
            (asserts! (not (get completed battle)) ERR-BATTLE-ALREADY-COMPLETED)

            ;; Only participants can resolve
            (asserts! (or (is-eq tx-sender challenger) (is-eq tx-sender defender)) ERR-NOT-AUTHORIZED)

            ;; Get creature stats for battle calculation
            (let
                (
                    (challenger-stats (unwrap! (map-get? creature-attributes challenger-creature) ERR-CREATURE-NOT-FOUND))
                    (defender-stats (unwrap! (map-get? creature-attributes defender-creature) ERR-CREATURE-NOT-FOUND))
                    (challenger-power (+ (get art-power challenger-stats) (get creativity challenger-stats) (get rarity challenger-stats)))
                    (defender-power (+ (get art-power defender-stats) (get creativity defender-stats) (get rarity defender-stats)))
                    (random-factor (get-random-uint u100))
                    (challenger-wins (> (+ challenger-power random-factor) defender-power))
                    (winner (if challenger-wins challenger defender))
                    (winner-creature (if challenger-wins challenger-creature defender-creature))
                )
                ;; Update battle result
                (map-set battles battle-id (merge battle { winner: (some winner), completed: true }))

                ;; Update winner's creature stats
                (map-set creature-attributes winner-creature
                    (merge (if challenger-wins challenger-stats defender-stats)
                        { battles-won: (+ (get battles-won (if challenger-wins challenger-stats defender-stats)) u1) }))

                ;; Update artist stats
                (match (map-get? artist-stats winner)
                    winner-stats
                    (map-set artist-stats winner
                        (merge winner-stats {
                            total-battles: (+ (get total-battles winner-stats) u1),
                            reputation: (+ (get reputation winner-stats) u5)
                        }))
                    true
                )

                (ok winner)
            )
        )
        ERR-BATTLE-NOT-FOUND
    )
)

;; Evolution System

;; Evolve creature (requires certain conditions)
(define-public (evolve-creature (creature-id uint))
    (let
        (
            (owner tx-sender)
        )
        ;; Check ownership
        (asserts! (is-eq (unwrap! (nft-get-owner? artherealms-creature creature-id) ERR-CREATURE-NOT-FOUND) owner)
            ERR-NOT-AUTHORIZED)

        (match (map-get? creature-attributes creature-id)
            creature-info
            (let
                (
                    (current-level (get evolution-level creature-info))
                    (battles-won (get battles-won creature-info))
                    (exhibitions-held (get exhibitions-held creature-info))
                )
                ;; Evolution requirements: at least 3 battles won and 2 exhibitions held
                (asserts! (>= battles-won u3) ERR-INSUFFICIENT-FUNDS)
                (asserts! (>= exhibitions-held u2) ERR-INSUFFICIENT-FUNDS)
                (asserts! (< current-level u5) ERR-INVALID-INPUT) ;; Max level 5

                ;; Evolution cost increases with level
                (let
                    (
                        (evolution-cost (* current-level u50000000)) ;; 0.05 STX per level
                    )
                    (try! (stx-transfer? evolution-cost tx-sender (as-contract tx-sender)))

                    ;; Upgrade creature stats
                    (map-set creature-attributes creature-id
                        (merge creature-info {
                            evolution-level: (+ current-level u1),
                            art-power: (+ (get art-power creature-info) u10),
                            creativity: (+ (get creativity creature-info) u8),
                            rarity: (+ (get rarity creature-info) u5)
                        }))

                    (ok (+ current-level u1))
                )
            )
            ERR-CREATURE-NOT-FOUND
        )
    )
)

;; Additional Read-Only Functions

;; Get exhibition details
(define-read-only (get-exhibition-details (exhibition-id uint))
    (match (map-get? exhibitions exhibition-id)
        exhibition-info (ok exhibition-info)
        ERR-EXHIBITION-NOT-FOUND
    )
)

;; Get battle details
(define-read-only (get-battle-details (battle-id uint))
    (match (map-get? battles battle-id)
        battle-info (ok battle-info)
        ERR-BATTLE-NOT-FOUND
    )
)

;; Check if user has voted for exhibition
(define-read-only (has-voted (exhibition-id uint) (voter principal))
    (is-some (map-get? exhibition-votes { exhibition-id: exhibition-id, voter: voter }))
)

;; Get contract info
(define-read-only (get-contract-info)
    (ok {
        total-creatures: (var-get last-token-id),
        total-exhibitions: (var-get last-exhibition-id),
        total-battles: (var-get last-battle-id),
        mint-price: (var-get mint-price),
        contract-owner: (var-get contract-owner)
    })
)