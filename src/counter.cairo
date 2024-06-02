#[starknet::contract]
mod Counter {
   
    #[storage]
    struct Storage {
        counter: u32, // --> Implemented on Step3        
    }

    #[constructor]
    fn constructor(ref self: ContractState, input: u32 )  {
        self.counter.write(input);  // --> Implemented on Step3       
    }
}

