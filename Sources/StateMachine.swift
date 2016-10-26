//
//  State.swift
//  StateMachine
//
//  Created by Benjamin P Toews on 10/26/16.
//
//

import Foundation

public class StateMachine<ContextType: StateMachineContext, StatusType>: NSObject {
    public typealias StateType  = State<ContextType, StatusType>
    public typealias Subscriber = (_ status: StatusType) -> Void
    
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
    func fail(_ message: String) {
        guard let next = failure else {
            return
        }
        
        proceed(next)
    }
    
    // Go to the next state.
    func proceed(_ next: StateType.Type) {
        current?.exit()
        let new = next.init(self)
        current = new
        new.enter()
    }
    
    // Subscribe to status updates from this machine.
    func subscribe(_ subscriber: @escaping Subscriber) {
        subscribers.append(subscriber)
    }
    
    // Notify subscribers about a status update.
    func statusUpdate(_ status: StatusType) {
        subscribers.forEach() { subscriber in
            subscriber(status)
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
