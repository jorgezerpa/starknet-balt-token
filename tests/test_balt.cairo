use starknet::{
    ContractAddress, 
    contract_address_const,
};

use snforge_std::{
    declare, 
    ContractClassTrait, 
    DeclareResultTrait,
    start_cheat_caller_address
};

use erc20_manual::Balt::IBaltSafeDispatcher;
use erc20_manual::Balt::IBaltSafeDispatcherTrait;

fn OWNER() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}
fn OTHER_USER() -> ContractAddress {
    contract_address_const::<'USER'>()
}
fn OTHER_USER_TWO() -> ContractAddress {
    contract_address_const::<'USER2'>()
}


fn deploy_contract(name:ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();

    let mut calldata: Array<felt252> = ArrayTrait::new();
    // add owner 
    // calldata.append(OWNER().into());

    // cheating caller address
    let contract_address = contract.precalculate_address(@calldata);
    start_cheat_caller_address(contract_address, OWNER());

    let (contract_address, _h) = contract.deploy(@calldata).unwrap();
    contract_address
}

#[test]
fn test_deploy () {
    let contract_address = deploy_contract("Balt");
    let dispatcher = IBaltSafeDispatcher { contract_address };
    
    let total_supply = dispatcher.get_total_supply().unwrap();
    let expected_total_supply:u256 = 20000000000000000000000000;
    
    let (name, symbol, decimals) = dispatcher.get_metadata().unwrap();
    let (expected_name, expected_symbol, expected_decimals) = ('Balt', 'BLT', 18_u8);
    
    let owner_balance = dispatcher.balance_of(OWNER()).unwrap();
    let expected_owner_balance = 20000000000000000000000000;
    
    assert_eq!(total_supply, expected_total_supply, "Total supply should be 20 million Balts");
    assert_eq!(name, expected_name, "Name should be 'Balt'");
    assert_eq!(symbol, expected_symbol, "Symbol should be 'BLT'");
    assert_eq!(decimals, expected_decimals, "Should have 18 decimal points");
    assert_eq!(owner_balance, expected_owner_balance, "Should have 18 decimal points");

}

#[test]
fn test_balance_of(){
    let contract_address = deploy_contract("Balt");
    let dispatcher = IBaltSafeDispatcher { contract_address };

    let owner_balance = dispatcher.balance_of(OWNER()).unwrap();
    let other_user_balance = dispatcher.balance_of(OTHER_USER()).unwrap();
    
    let expected_owner_balance = 20000000000000000000000000;
    let expected_other_user_balance = 0;

    assert_eq!(owner_balance, expected_owner_balance, "Balance of owner should be wqual to total supply initially");
    assert_eq!(other_user_balance, expected_other_user_balance, "Balance of any other user should be 0 initially");
}

#[test]
fn test_transfer(){
    let contract_address = deploy_contract("Balt");
    let dispatcher = IBaltSafeDispatcher { contract_address };

    let amount_to_transfer:u256 = 1000000000000000000;

    let pre_transfer_owner_balance = dispatcher.balance_of(OWNER()).unwrap();
    let pre_transfer_other_user_balance = dispatcher.balance_of(OTHER_USER()).unwrap();

    let transfer_result = dispatcher.transfer(OTHER_USER(), amount_to_transfer).unwrap();
    println!("transfer result -> {}", transfer_result);

    let post_transfer_owner_balance = dispatcher.balance_of(OWNER()).unwrap();
    let post_transfer_other_user_balance = dispatcher.balance_of(OTHER_USER()).unwrap();

    assert_eq!(pre_transfer_owner_balance-amount_to_transfer, post_transfer_owner_balance, "Owner balance should decrease the transfered amount");
    assert_eq!(pre_transfer_other_user_balance+amount_to_transfer, post_transfer_other_user_balance, "Recipient balance should increase the transfered amount");
}

#[test]
fn test_approve_and_allowance(){
    let contract_address = deploy_contract("Balt");
    let dispatcher = IBaltSafeDispatcher { contract_address };

    let amount_to_approve = 10000000000000000000;
    let address_to_approve = OTHER_USER();

    dispatcher.approve(address_to_approve, amount_to_approve).unwrap();

    start_cheat_caller_address(contract_address, address_to_approve);

    let approved_amount = dispatcher.allowance(OWNER()).unwrap();

    assert_eq!(approved_amount, amount_to_approve, "Approved amount should be 10 balts");
}

#[test]
fn test_transfer_from(){
    let contract_address = deploy_contract("Balt");
    let dispatcher = IBaltSafeDispatcher { contract_address };

    // approving amount
    let amount_to_approve = 10000000000000000000;
    let address_to_approve = OTHER_USER();
    dispatcher.approve(address_to_approve, amount_to_approve).unwrap();
    
    let prev_owner_balance = dispatcher.balance_of(OWNER()).unwrap(); 
    let prev_user2_balance = dispatcher.balance_of(OTHER_USER_TWO()).unwrap(); 
    
    start_cheat_caller_address(contract_address, address_to_approve);
    let amount_to_transfer = 5000000000000000000;
    dispatcher.transfer_from(OWNER(), OTHER_USER_TWO(), amount_to_transfer).unwrap();
    
    let post_owner_balance = dispatcher.balance_of(OWNER()).unwrap(); 
    let post_user2_balance = dispatcher.balance_of(OTHER_USER_TWO()).unwrap();
    println!("post user -> {}", post_user2_balance); 

    assert_eq!(prev_owner_balance-amount_to_transfer, post_owner_balance, "Owner balance should decrease 5 Balts");
    assert_eq!(prev_user2_balance+amount_to_transfer, post_user2_balance, "User2 balance should increase 5 Balts");
}



// later when implementing error handling 
// #[test]
// fn test_transfer_should_fail(){
//     let contract_address = deploy_contract("Balt");
//     let dispatcher = IBaltSafeDispatcher { contract_address };

//     let amount_to_transfer:u256 = 1000000000000000000;

//     let pre_transfer_owner_balance = dispatcher.balance_of(OWNER()).unwrap();
//     let pre_transfer_other_user_balance = dispatcher.balance_of(OTHER_USER()).unwrap();

//     let transfer_result = dispatcher.transfer(OTHER_USER(), amount_to_transfer).unwrap();
//     println!("transfer result -> {}", transfer_result);

//     let post_transfer_owner_balance = dispatcher.balance_of(OWNER()).unwrap();
//     let post_transfer_other_user_balance = dispatcher.balance_of(OTHER_USER()).unwrap();

//     assert_eq!(pre_transfer_owner_balance-amount_to_transfer, post_transfer_owner_balance, "Owner balance should decrease the transfered amount");
//     assert_eq!(pre_transfer_other_user_balance+amount_to_transfer, post_transfer_other_user_balance, "Recipient balance should increase the transfered amount");
// }


