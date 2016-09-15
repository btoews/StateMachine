//
//  StateMachine.swift
//  StateMachine
//
//  Created by Benjamin P Toews on 9/7/16.
//
//

import Foundation

class StateMachine<ContextType: StateMachineContext, StatusType>: NSObject {
    typealias StateType  = State<ContextType, StatusType>
    typealias Subscriber = (status: StatusType) -> Void
    
    var current: StateType?
    var failure: StateType.Type?
    var subscribers: [Subscriber] = []
    let context = ContextType()
    
    // Name of current state. For debugging.
    var currentName: String {
        return current == nil ? "<nil state>" : "\(current)"
    }
    
    // Callback to reset things that can only happen here.
    func reset() {
    }
    
    // Go to failure state.
    func fail(message: String) {
        print("Failing at \(currentName) because \(message)")
        
        guard let next = failure else {
            print("No failure state. State machine finished.")
            return
        }
        
        proceed(next)
    }
    
    // Go to the next state.
    func proceed(next: StateType.Type) {
        current?.exit()
        let new = next.init(self)
        current = new
        new.enter()
    }
    
    // Subscribe to status updates from this machine.
    func subscribe(subscriber: Subscriber) {
        subscribers.append(subscriber)
    }
    
    // Notify subscribers about a status update.
    func statusUpdate(status: StatusType) {
        subscribers.forEach() { subscriber in
            subscriber(status: status)
        }
    }
    
    // Send an event to the current state.
    func handle(event name: String) {
        guard let state = current else { return }
        
        if let handler = state.eventHandlers[name] {
            handler()
        } else {
            fail("unhandled '\(name)' event")
        }
    }
}