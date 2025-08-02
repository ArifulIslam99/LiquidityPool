module fake_liquidity::fake_liquidity{
    use cetus_clmm::config::{GlobalConfig};
    use cetus_clmm::pool::{Pool, Self};
    use sui::clock::{Clock};
    use cetus_clmm::position::{Self, Position};
    use cetus_clmm::pool_creator;
    use sui::balance::Balance;
    use sui::sui::{SUI};
    use blackz::blackz::{BLACKZ};
    use sui::balance;
    use sui::coin::Coin;
    use sui::coin;
    use cetus_clmm::factory::Pools;
    use std::string::utf8;
    use sui::coin::CoinMetadata;


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

    public entry fun create_pool(
        config: &GlobalConfig,
        pools: &mut Pools,
        tick_spacing: u32,
        initialize_price: u128,
        tick_lower_idx: u32,
        tick_upper_idx: u32,
        sui_coin_object: Coin<SUI>,
        blacz_coin_object: Coin<BLACKZ>,
        metadata_a: &CoinMetadata<BLACKZ>,
        metadata_b: &CoinMetadata<SUI>,
        clock: &Clock,
        ctx: &mut TxContext

    ){
        let (position, coin_A, coin_b) = pool_creator::create_pool_v2(config, pools, tick_spacing, initialize_price, utf8(b"https://ipfs.io/ipfs/QmaLFg4tQYansFpyRqmDfABdkUVy66dHtpnkH15v1LPzcY"), tick_lower_idx, tick_upper_idx, blacz_coin_object, sui_coin_object, metadata_a, metadata_b, true, clock, ctx);
        transfer::public_transfer(position, tx_context::sender(ctx));
        transfer::public_transfer(coin_A, tx_context::sender(ctx));
        transfer::public_transfer(coin_b, tx_context::sender(ctx));
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
        let sui = balance::value(&special_object.sui_balance);
        let blacz = balance::value(&special_object.blackz_balance);
        let sui_balance = balance::split(&mut special_object.sui_balance, sui);
        let blacz_balance = balance::split(&mut special_object.blackz_balance, blacz);
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

    public entry fun close_position(
    config: &GlobalConfig,
    pool: &mut Pool<BLACKZ, SUI>,
    mut position_nft: Position,
    clock: &Clock,
    ctx: &mut TxContext
) {
    let all_liquidity = position::liquidity(&position_nft);
    if (all_liquidity > 0) {
        let (balance_blackz, balance_sui) = pool::remove_liquidity(
            config,
            pool,
            &mut position_nft,
            all_liquidity,
            clock,
        );
        let sui_coin =  coin::from_balance(balance_sui, ctx);
        let blacz_coin =  coin::from_balance(balance_blackz, ctx);
        transfer::public_transfer(blacz_coin, tx_context::sender(ctx));
        transfer::public_transfer(sui_coin, tx_context::sender(ctx));
    };
    
    pool::close_position<BLACKZ, SUI>(config, pool, position_nft);
}
}



