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

protocol ContextProtocol {
    init()
}

class StateMachine<ContextType: ContextProtocol> {
    var current: State<ContextType>?
    var failure: State<ContextType>?
    var context = ContextType()
    
    var currentName: String { return current != nil ? "\(current)" : "<nil state>" }
    
    func fail(because message: String) {
        print("Failing at \(currentName) because \(message)")
        
        guard let next = failure else {
            print("No failure state. State machine finished.")
            return
        }
        
        proceed(to: next)
    }
    
    func proceed(to new: State<ContextType>) {
        do {
            current?.beforeExit()
            try current?.exit()
            current = new
            new.beforeEnter()
            try new.enter()
        } catch {
            fail(because: "unknwon error")
        }
    }
    
    func handle(event name: String, error: NSError? = nil) {
        do {
            try current?.handle(event: name, error: error)
        } catch StateError.UnhandledEvent {
            fail(because: "unhandled '\(name)' event")
        } catch {
            fail(because: "unknwon error while handling '\(name)' event")
        }
    }
}

class State<ContextType: ContextProtocol> {
    var machine: StateMachine<ContextType>
    var eventHandlers: [String:(error: NSError?) -> Void] = [:]
    var context: ContextType { return machine.context }
    
    init(_ m: StateMachine<ContextType>) {
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
        print("Exiting \(self)")
    }
    
    // Callback when exiting state.
    func exit() throws {
    }
    
    func handle(event name: String, error: NSError? = nil) throws {
        if let handler = eventHandlers[name] {
            handler(error: error)
        } else {
            throw StateError.UnhandledEvent
        }
    }
    
    func handle(event name: String, with function: (error: NSError?) -> Void) {
        eventHandlers[name] = function
    }
}