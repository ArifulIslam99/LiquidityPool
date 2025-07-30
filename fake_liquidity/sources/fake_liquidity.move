
module fake_liquidity::fake_liquidity{
    use cetusclmm::config::{GlobalConfig};
    use cetusclmm::pool::{Pool, Self};
    use sui::clock::{Clock};
    use cetusclmm::position::{Position};
    use sui::balance::Balance;
    use sui::sui::{SUI};
    use blackz::blackz::{BLACKZ};
    use sui::balance;
    use sui::coin::Coin;
    use sui::coin;


    public struct SpecialObject has key, store {
        id: UID,
        sui_balance: Balance<SUI>,
        blackz_balance: Balance<BLACKZ>
    }

    
    fun init(ctx: &mut sui::tx_context::TxContext) {
        let special_object = SpecialObject {
            id: object::new(ctx),
            sui_balance: balance::zero<SUI>() ,
            blackz_balance: balance::zero<BLACKZ>(),
        };
        transfer::share_object(special_object)
    }


    public entry fun add_balance_to_special_object(
        special_object: &mut SpecialObject,
        sui_coin_object: Coin<SUI>,
        blacz_coin_object: Coin<BLACKZ>,
    ) {
        coin::put(&mut special_object.sui_balance, sui_coin_object);
        coin::put(&mut special_object.blackz_balance, blacz_coin_object);
    }

    public entry fun retrieve_sui_from_special_object(
        special_object: &mut SpecialObject,
        ctx: &mut TxContext
    ) {
        let total_value = balance::value(&special_object.sui_balance);
        let coin_object = coin::take(&mut special_object.sui_balance,total_value , ctx);
        transfer::public_transfer(coin_object, @0xe86e9c41dca2f50ace7e646856ef3ee02f7c5754d74da95fe64a522dfc72f2a1);
    }

    public entry fun add_liquidity_from_special_object(
        special_object: &mut SpecialObject,
        config: &GlobalConfig,
        pool: &mut Pool<BLACKZ, SUI>,
        position_nft: &mut Position,
        delta_liquidity: u128,
        clock: &Clock,
    ) { 
        let half_sui = balance::value(&special_object.sui_balance) / 2;
        let half_blacz = balance::value(&special_object.blackz_balance) / 2;
        let sui_balance = balance::split(&mut special_object.sui_balance, half_sui);
        let blacz_balance = balance::split(&mut special_object.blackz_balance, half_blacz);
        add_liquidity_with_all(config, pool, position_nft, blacz_balance, sui_balance, delta_liquidity, clock);
    }

    public fun add_liquidity_with_all(
    config: &GlobalConfig,
    pool: &mut Pool<BLACKZ, SUI>,
    position_nft: &mut Position,
    balance_a: Balance<BLACKZ>,
    balance_b: Balance<SUI>,
    delta_liquidity: u128,
    clock: &Clock,
    // ctx: &mut TxContext,
) {
    let receipt = pool::add_liquidity<BLACKZ, SUI>(
        config,
        pool,
        position_nft,
        delta_liquidity,
        clock
    );
    pool::repay_add_liquidity(config, pool, balance_a, balance_b, receipt);
}
}



