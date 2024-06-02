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
    use openzeppelin::access::ownable::OwnableComponent; //--> Implemented on Step12

    component!(path: OwnableComponent, storage: ownable, event: OEvent); //--> Implemented on Step12

    #[abi(embed_v0)] 
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>; //--> Implemented on Step12
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>; //--> Implemented on Step12

    #[event]
    #[derive(Drop, starknet::Event)] //--> Implemented on Step6
    enum Event {
        CounterIncreased: CounterIncreased, //--> Implemented on Step6
        OEvent: OwnableComponent::Event, //--> Implemented on Step12
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
        #[substorage(v0)] 
        ownable: OwnableComponent::Storage, //--> Implemented on Step12
    }

    #[constructor]
    fn constructor(ref self: ContractState, input: u32, ks_address: ContractAddress, initial_owner: ContractAddress )  {
        self.counter.write(input);  // --> Implemented on Step5
        self.kill_switch.write(ks_address);  // --> Implemented on Step8
        self.ownable.initializer(initial_owner); // --> Implemented on Step13
    }

    #[abi(embed_v0)]
    impl ImplCounter of ICounter<ContractState> {
        // Implemented on Step4
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }
        fn increase_counter(ref self: ContractState) { 
            let ks_address = self.kill_switch.read(); // --> Implemented on Step9  
            if (IKillSwitchDispatcher { contract_address: ks_address }.is_active()) { // --> Implemented on Step9  
                self.counter.read(); // --> Implemented on Step9. I run step10 with and without this line and it passed.
                panic!("Kill Switch is active"); // --> Implemented on Step10                        
            } else {           
                self.ownable.assert_only_owner(); // --> Implemented on Step14
                self.counter.write(self.counter.read() + 1);  // --> Implemented on Step5
                self.emit(CounterIncreased{counter: self.counter.read()});  // --> Implemented on Step6
            }
        }
    }
}

