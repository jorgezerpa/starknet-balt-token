#[starknet::contract]
pub mod Balt {
    use starknet::storage::StoragePathEntry;
    use starknet::{ContractAddress, get_caller_address};
    use core::starknet::storage::{Map};
    
    #[starknet::interface]
    pub trait IBalt<TContractState> {

        fn get_metadata(self: @TContractState) -> (felt252, felt252, u8);

        fn get_total_supply(self: @TContractState) -> u256;
        fn balance_of(self: @TContractState, address:ContractAddress)-> u256;
        
        fn transfer(ref self: TContractState, recipient:ContractAddress, amount:u256) -> bool;
        
        fn transfer_from(ref self: TContractState, owner:ContractAddress, recipient:ContractAddress, amount:u256) -> bool;
        fn approve(ref self: TContractState, spender:ContractAddress, amount:u256) -> bool;
        fn allowance(ref self: TContractState, owner: ContractAddress) -> u256;
    }

    
    #[storage]
    struct Storage {
        total_supply: u256,
        name:felt252,
        symbol:felt252,
        decimals:u8,
        balances: Map::<ContractAddress, u256>,
        allowances: Map::<ContractAddress, Map::<ContractAddress, u256>>, // owner -> allowed-quantity
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.total_supply.write(20000000000000000000000000); // 20
        self.decimals.write(18);
        self.symbol.write('BLT');
        self.name.write('Balt');

        let owner_address = get_caller_address();

        self.balances.entry(owner_address).write(20000000000000000000000000);
    }
    
    
    #[abi(embed_v0)]
    impl BaltImpl of IBalt<ContractState> {

        fn get_metadata(self:@ContractState) -> (felt252, felt252, u8) {
            let name = self.name.read();
            let symbol = self.symbol.read();
            let decimals = self.decimals.read();

            (name,symbol,decimals)
        }

        fn get_total_supply(self:@ContractState) -> u256 {
            self.total_supply.read()
        }
        fn balance_of(self: @ContractState, address:ContractAddress) -> u256 {
            let balance = self.balances.read(address);
            balance
        }
        
        fn transfer(ref self: ContractState, recipient:ContractAddress, amount:u256) -> bool {
            let caller_address = get_caller_address();
            let caller_balance = self.balances.read(caller_address);
            println!("caller balance from contract {}", caller_balance);
            if caller_balance < amount {
                return false;
            }
            
            let recipient_balance = self.balances.read(recipient);

            self.balances.write(caller_address, caller_balance - amount);
            self.balances.write(recipient, recipient_balance + amount);
            
            true
        }
        
        fn transfer_from(ref self: ContractState, owner:ContractAddress, recipient:ContractAddress, amount:u256) -> bool {
            let spender = get_caller_address();
            let allowed_amount = self.allowances.entry(owner).read(spender);
            if allowed_amount < amount {
                return false;
            }
            
            let owner_balance = self.balances.read(owner);
            if owner_balance < amount {
                return false;
            }

            let recipient_balance = self.balances.read(recipient);
            
            self.balances.write(owner, owner_balance - amount);
            self.balances.write(recipient, recipient_balance + amount);

            true
        }
        
        fn approve(ref self: ContractState, spender:ContractAddress, amount:u256) -> bool {
            let caller_address = get_caller_address();
            self.allowances.entry(caller_address).write(spender, amount);
            true
        }
        
        fn allowance(ref self: ContractState, owner: ContractAddress) -> u256 {
            let spender = get_caller_address();
            self.allowances.entry(owner).read(spender)
        }
    }
}

// #[starknet::contract]
// mod HelloStarknet {
//     #[storage]
//     struct Storage {
//         balance: felt252, 
//     }

//     #[abi(embed_v0)]
//     impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
//         fn increase_balance(ref self: ContractState, amount: felt252) {
//             assert(amount != 0, 'Amount cannot be 0');
//             self.balance.write(self.balance.read() + amount);
//         }

//         fn get_balance(self: @ContractState) -> felt252 {
//             self.balance.read()
//         }
//     }
// }
