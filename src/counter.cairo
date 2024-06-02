#[starknet::interface]
trait ICounter<T> {
    fn get_counter(self: @T) -> u32; // --> Implemented on Step4
    fn increase_counter(ref self: T); // --> Implemented on Step5
}

#[starknet::contract]
mod Counter {
    use super::ICounter;
    use starknet::ContractAddress; //--> Implemented on Step8
    use kill_switch::IKillSwitchDispatcher; //--> Implemented on Step8
    use kill_switch::IKillSwitchDispatcherTrait; //--> Implemented on Step8
    

    #[event]
    #[derive(Drop, starknet::Event)] //--> Implemented on Step6
    enum Event {
        CounterIncreased: CounterIncreased, //--> Implemented on Step6
        
    }

    #[derive(Drop, starknet::Event)] //--> Implemented on Step6
    struct CounterIncreased {
        #[key]
        counter: u32, //--> Implemented on Step6
    }

    #[storage]
    struct Storage {
        counter: u32, // --> Implemented on Step3
        kill_switch: ContractAddress, // --> Implemented on Step8        
    }

    #[constructor]
    fn constructor(ref self: ContractState, input: u32, ks_address: ContractAddress )  {
        self.counter.write(input);  // --> Implemented on Step5
        self.kill_switch.write(ks_address);  // --> Implemented on Step8
    }

    #[abi(embed_v0)]
    impl ImplCounter of ICounter<ContractState> {
        // Implemented on Step4
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }
        fn increase_counter(ref self: ContractState) { 
            
            self.counter.write(self.counter.read() + 1);  // --> Implemented on Step5
            self.emit(CounterIncreased{counter: self.counter.read()});  // --> Implemented on Step6
        }
    }
}

