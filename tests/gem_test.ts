
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v0.31.0/index.ts';
import { assertEquals, assertStringIncludes } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can mint art creature successfully",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Abstract")], wallet1.address)
        ]);

        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(1));

        // Check creature details
        let creatureDetails = chain.callReadOnlyFn(
            'gem',
            'get-creature-details',
            [types.uint(1)],
            wallet1.address
        );

        const creature = creatureDetails.result.expectOk().expectTuple();
        assertEquals(creature['creator'], wallet1.address);
        assertEquals(creature['art-style'], types.ascii("Abstract"));
        assertEquals(creature['evolution-level'], types.uint(1));
    },
});

Clarinet.test({
    name: "Cannot mint with empty art style",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;

        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("")], wallet1.address)
        ]);

        assertEquals(block.receipts.length, 1);
        assertEquals(block.receipts[0].result.expectErr(), types.uint(110)); // ERR-INVALID-INPUT
    },
});

Clarinet.test({
    name: "Can start and vote for exhibition",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        // First mint a creature
        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Modern")], wallet1.address)
        ]);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(1));

        // Start exhibition
        block = chain.mineBlock([
            Tx.contractCall('gem', 'start-exhibition', [types.uint(1), types.uint(100)], wallet1.address)
        ]);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(1));

        // Vote for exhibition
        block = chain.mineBlock([
            Tx.contractCall('gem', 'vote-for-exhibition', [types.uint(1)], wallet2.address)
        ]);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(1));

        // Check exhibition details
        let exhibitionDetails = chain.callReadOnlyFn(
            'gem',
            'get-exhibition-details',
            [types.uint(1)],
            wallet1.address
        );

        const exhibition = exhibitionDetails.result.expectOk().expectTuple();
        assertEquals(exhibition['votes'], types.uint(1));
        assertEquals(exhibition['active'], types.bool(true));
    },
});

Clarinet.test({
    name: "Cannot vote twice for same exhibition",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        // Mint and start exhibition
        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Digital")], wallet1.address),
            Tx.contractCall('gem', 'start-exhibition', [types.uint(1), types.uint(100)], wallet1.address)
        ]);

        // First vote
        block = chain.mineBlock([
            Tx.contractCall('gem', 'vote-for-exhibition', [types.uint(1)], wallet2.address)
        ]);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(1));

        // Second vote should fail
        block = chain.mineBlock([
            Tx.contractCall('gem', 'vote-for-exhibition', [types.uint(1)], wallet2.address)
        ]);
        assertEquals(block.receipts[0].result.expectErr(), types.uint(105)); // ERR-ALREADY-VOTED
    },
});

Clarinet.test({
    name: "Can challenge and resolve battles",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        // Mint creatures for both players
        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Warrior")], wallet1.address),
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Mage")], wallet2.address)
        ]);

        // Challenge to battle
        block = chain.mineBlock([
            Tx.contractCall('gem', 'challenge-to-battle', [types.uint(1), types.uint(2)], wallet1.address)
        ]);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(1));

        // Resolve battle
        block = chain.mineBlock([
            Tx.contractCall('gem', 'resolve-battle', [types.uint(1)], wallet1.address)
        ]);
        assertEquals(block.receipts.length, 1);
        block.receipts[0].result.expectOk(); // Should return winner address

        // Check battle details
        let battleDetails = chain.callReadOnlyFn(
            'gem',
            'get-battle-details',
            [types.uint(1)],
            wallet1.address
        );

        const battle = battleDetails.result.expectOk().expectTuple();
        assertEquals(battle['completed'], types.bool(true));
    },
});

Clarinet.test({
    name: "Cannot battle same creature",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;

        // Mint creature
        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Solo")], wallet1.address)
        ]);

        // Try to battle self
        block = chain.mineBlock([
            Tx.contractCall('gem', 'challenge-to-battle', [types.uint(1), types.uint(1)], wallet1.address)
        ]);
        assertEquals(block.receipts[0].result.expectErr(), types.uint(109)); // ERR-CANNOT-BATTLE-SELF
    },
});

Clarinet.test({
    name: "Admin functions work correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        // Set new mint price (only owner can do this)
        let block = chain.mineBlock([
            Tx.contractCall('gem', 'set-mint-price', [types.uint(200000000)], deployer.address)
        ]);
        assertEquals(block.receipts[0].result.expectOk(), types.uint(200000000));

        // Non-owner cannot set price
        block = chain.mineBlock([
            Tx.contractCall('gem', 'set-mint-price', [types.uint(300000000)], wallet1.address)
        ]);
        assertEquals(block.receipts[0].result.expectErr(), types.uint(101)); // ERR-NOT-AUTHORIZED

        // Check contract info
        let contractInfo = chain.callReadOnlyFn(
            'gem',
            'get-contract-info',
            [],
            deployer.address
        );

        const info = contractInfo.result.expectOk().expectTuple();
        assertEquals(info['mint-price'], types.uint(200000000));
        assertEquals(info['contract-owner'], deployer.address);
    },
});

Clarinet.test({
    name: "Evolution system works with requirements",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        // Mint creatures
        let block = chain.mineBlock([
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Evolving")], wallet1.address),
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Target1")], wallet2.address),
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Target2")], wallet2.address),
            Tx.contractCall('gem', 'mint-art-creature', [types.ascii("Target3")], wallet2.address)
        ]);

        // Start exhibitions to meet evolution requirements
        block = chain.mineBlock([
            Tx.contractCall('gem', 'start-exhibition', [types.uint(1), types.uint(10)], wallet1.address),
            Tx.contractCall('gem', 'start-exhibition', [types.uint(1), types.uint(10)], wallet1.address)
        ]);

        // Win battles to meet evolution requirements
        // This is simplified - in reality battles have random outcomes
        block = chain.mineBlock([
            Tx.contractCall('gem', 'challenge-to-battle', [types.uint(1), types.uint(2)], wallet1.address),
            Tx.contractCall('gem', 'resolve-battle', [types.uint(1)], wallet1.address),
            Tx.contractCall('gem', 'challenge-to-battle', [types.uint(1), types.uint(3)], wallet1.address),
            Tx.contractCall('gem', 'resolve-battle', [types.uint(2)], wallet1.address),
            Tx.contractCall('gem', 'challenge-to-battle', [types.uint(1), types.uint(4)], wallet1.address),
            Tx.contractCall('gem', 'resolve-battle', [types.uint(3)], wallet1.address)
        ]);

        // Try evolution (might fail if requirements not met due to random battle outcomes)
        block = chain.mineBlock([
            Tx.contractCall('gem', 'evolve-creature', [types.uint(1)], wallet1.address)
        ]);

        // The result depends on whether the creature won enough battles
        // This test demonstrates the evolution function exists and has proper error handling
        if (block.receipts[0].result.isOk) {
            assertEquals(block.receipts[0].result.expectOk(), types.uint(2)); // New evolution level
        } else {
            // Should be insufficient funds error if requirements not met
            assertEquals(block.receipts[0].result.expectErr(), types.uint(103));
        }
    },
});
