//
//  StateMachine.swift
//  StateMachine
//
//  Created by Benjamin P Toews on 9/7/16.
//
//

import Foundation

enum StateError: ErrorType {
    case UnhandledEvent
}

class StateMachine<ContextType: ContextProtocol>: NSObject {
    var current: State<ContextType>?
    var failure: State<ContextType>.Type?
    let context = ContextType()
    
    // Name of current state. For debugging.
    var currentName: String {
        if let c = current { return "\(c)" }
        return "<nil state>"
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
    func proceed(next: State<ContextType>.Type) {
        do {
            current?.beforeExit()
            try current?.exit()
            let new = next.init(self)
            current = new
            new.beforeEnter()
            try new.enter()
        } catch {
            fail("unknown error")
        }
    }
    
    // Send an event to the current state.
    func handle(event name: String) {
        do {
            try current?.handle(event: name)
        } catch StateError.UnhandledEvent {
            fail("unhandled '\(name)' event")
        } catch {
            fail("unknown error while handling '\(name)' event")
        }
    }
}