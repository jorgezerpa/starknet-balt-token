use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

// use erc20_manual::Balt::IBaltDispatcher;
// use erc20_manual::Balt::IBaltDispatcherTrait;
use erc20_manual::Balt::IBaltSafeDispatcher;
use erc20_manual::Balt::IBaltSafeDispatcherTrait;


fn deploy_contract(name:ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _h) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}
#[test]
fn test_deploy () {
    let contract_address = deploy_contract("Balt");
    let dispatcher = IBaltSafeDispatcher { contract_address };

    // let name = dispatcher.;
    
    let total_supply = dispatcher.get_total_supply().unwrap();
    let expected_total_supply:u256 = 20000000000000000000000000;

    let (name, symbol, decimals) = dispatcher.get_metadata().unwrap();

    assert_eq!(total_supply, expected_total_supply, "Total supply should be 20 million Balts");
    assert_eq!(name, 'Balt', "Name should be 'Balt'");
    assert_eq!(symbol, 'BLT', "Symbol should be 'BLT'");
    assert_eq!(decimals, 18_u8, "Should have 18 decimal points");
}


// use starknet::ContractAddress;

// use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

// use erc20_manual::IHelloStarknetSafeDispatcher;
// use erc20_manual::IHelloStarknetSafeDispatcherTrait;
// use erc20_manual::IHelloStarknetDispatcher;
// use erc20_manual::IHelloStarknetDispatcherTrait;

// fn deploy_contract(name: ByteArray) -> ContractAddress {
//     let contract = declare(name).unwrap().contract_class();
//     let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
//     contract_address
// }

// #[test]
// fn test_increase_balance() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let dispatcher = IHelloStarknetDispatcher { contract_address };

//     let balance_before = dispatcher.get_balance();
//     assert(balance_before == 0, 'Invalid balance');

//     dispatcher.increase_balance(42);

//     let balance_after = dispatcher.get_balance();
//     assert(balance_after == 42, 'Invalid balance');
// }

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("HelloStarknet");

//     let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }
