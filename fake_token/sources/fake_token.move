module blackz::blackz {
    use sui::coin::{Self, TreasuryCap, Coin};
    // use sui::object::{Self, UID};
    use sui::url;
    use std::ascii;

    public struct BLACKZ has drop {}
    


    #[allow(lint(share_owned))]
    fun init(otw: BLACKZ, ctx: &mut TxContext) {
        let (mut treasury_cap, metadata) = coin::create_currency(
            otw,
            9,
            b"BLZ",
            b"BLACKZ",
            b"Currency of Fake protocol!",
            option::some(url::new_unsafe(ascii::string(b"https://indigo-elderly-aardwolf-635.mypinata.cloud/ipfs/QmYqLMBatiRkwvZ7AyGrE3wz7FwTS1xpKejTP4Bg3JimtG"))),
            ctx,
        );

        let amount: u64 = 10000000000;
        coin::mint_and_transfer(&mut treasury_cap, amount * 1000000000, tx_context::sender(ctx), ctx);
        transfer::public_share_object(metadata);
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    public entry fun burn_coin(cap: &mut TreasuryCap<BLACKZ>, coins: Coin<BLACKZ>) {
        coin::burn(cap, coins);
    }
}
