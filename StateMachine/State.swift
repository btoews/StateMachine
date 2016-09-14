//
//  State.swift
//  StateMachine
//
//  Created by Benjamin P Toews on 9/14/16.
//
//

import Foundation

class State<ContextType: StateMachineContext> {
    let machine: StateMachine<ContextType>
    var eventHandlers: [String:() -> Void] = [:]
    var context: ContextType { return machine.context }
    
    required init(_ m: StateMachine<ContextType>) {
        machine = m
    }
    
    // Debugging callback.
    func beforeEnter() {
        print("Entering \(self)")
    }
    
    // Callback when entering state.
    func enter() throws {
    }
    
    // Debugging callback.
    func beforeExit() {
    }
    
    // Callback when exiting state.
    func exit() throws {
    }
    
    // Go to the next state.
    func proceed(next: State.Type) {
        machine.proceed(next)
    }
    
    // Go to failure state.
    func fail(message: String) {
        machine.fail(message)
    }
    
    // Handle an event, or error out.
    func handle(event name: String) throws {
        if let handler = eventHandlers[name] {
            handler()
        } else {
            throw StateError.UnhandledEvent
        }
    }
    
    // Register an event handler.
    func handle(event name: String, with function: () -> Void) {
        eventHandlers[name] = function
    }
}