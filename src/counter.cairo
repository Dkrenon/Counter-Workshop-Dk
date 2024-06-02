#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32; // --> Implemented on Step4
    fn increase_counter(ref self: T); // --> Implemented on Step5
}

#[starknet::contract]
mod Counter {
    use super::ICounter;    

    #[storage]
    struct Storage {
        counter: u32, // --> Implemented on Step3
    }

    #[constructor]
    fn constructor(ref self: ContractState, input: u32 )  {
        self.counter.write(input);  // --> Implemented on Step3        
    }

    #[abi(embed_v0)]
    impl ImplCounter of ICounter<ContractState> {
        // Implemented on Step4
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }
        fn increase_counter(ref self: ContractState) { 
           
            self.counter.write(self.counter.read() + 1);  // --> Implemented on Step5                    
        }
    }
}

