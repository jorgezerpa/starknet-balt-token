#[starknet::contract]
pub mod Balt {
    use starknet::ContractAddress;
    
    #[starknet::interface]
    pub trait IBalt<TContractState> {

        fn get_metadata(self: @TContractState) -> (felt252, felt252, u8);

        fn get_total_supply(self: @TContractState) -> u256;
        fn balance_of(self: @TContractState, address:ContractAddress)-> u256;
        
        fn transfer(ref self: TContractState, recipient:ContractAddress, amount:u256) -> bool;
        
        fn transfer_from(ref self: TContractState, owner:ContractAddress, recipient:ContractAddress, amount:u256) -> bool;
        fn approve(ref self: TContractState, spender:ContractAddress, amount:u256) -> bool;
        fn allowance(ref self: TContractState, owner: ContractAddress, spender:ContractAddress) -> u256;
    }
    
    #[storage]
    struct Storage {
        total_supply: u256,
        name:felt252,
        symbol:felt252,
        decimals:u8,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.total_supply.write(20000000000000000000000000); // 20
        self.decimals.write(18);
        self.symbol.write('BLT');
        self.name.write('Balt');
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
            5_u256
        }
        
        fn transfer(ref self: ContractState, recipient:ContractAddress, amount:u256) -> bool {
            true
        }
        
        fn transfer_from(ref self: ContractState, owner:ContractAddress, recipient:ContractAddress, amount:u256) -> bool {
            true
        }

        fn approve(ref self: ContractState, spender:ContractAddress, amount:u256) -> bool {
            true
        }
        
        fn allowance(ref self: ContractState, owner: ContractAddress, spender:ContractAddress) -> u256 {
            5_u256
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
