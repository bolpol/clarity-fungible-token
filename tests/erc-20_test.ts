import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.4.2/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

function mint(
    account: Account,
    amount: number,
    sender: Account
) {
    return Tx.contractCall(
        "erc-20",
        "mint",
        [
            types.uint(amount),
            types.principal(account.address),
        ],
        sender.address
    );
}

function transfer(
    from: Account,
    to: Account,
    amount: number,
    sender: Account
) {
    return Tx.contractCall(
        "erc-20",
        "transfer",
        [
            types.principal(from.address),
            types.principal(to.address),
            types.uint(amount),
        ],
        sender.address
    );
}

Clarinet.test({
    name: "get-count returns u0 for principals that never called count-up before",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        // Get the deployer account.
        let deployer = accounts.get("deployer")!;
        console.log(deployer)

        // Call the get-count read-only function.
        // The first parameter is the contract name, the second the
        // function name, and the third the function arguments as
        // an array. The final parameter is the tx-sender.
        let count = chain.callReadOnlyFn("erc-20", "decimals", [], deployer.address);

        // Assert that the returned result is a uint with a value of 0 (u0).
        // count.result.expectTypes("", 6);
        assertEquals(count.result, '(ok u6)', "Invalid decimals")
    },
});

Clarinet.test({
    name: "#mint",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        // Get the deployer account.
        let deployer = accounts.get("deployer")!;
        console.log(deployer)

        let block = chain.mineBlock([
            mint(deployer, 10000, deployer)
        ]);

        let balance0 = chain.callReadOnlyFn("erc-20", "balance-of", [types.principal(deployer.address)], deployer.address);

        console.log(balance0.result)
        assertEquals(balance0.result, '(ok u10000)', "Invalid balance")
    },
});


