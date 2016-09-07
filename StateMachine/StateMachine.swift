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

class StateMachine<ContextType: ContextProtocol>: NSObject {
    var current: State<ContextType>?
    var failure: State<ContextType>.Type?
    var context = ContextType()
    
    var currentName: String {
        if let c = current { return "\(c)" }
        return "<nil state>"
    }
    
    // Callback to reset things that can only happen here.
    func reset() {
    }
    
    func fail(message: String) {
        print("Failing at \(currentName) because \(message)")
        
        guard let next = failure else {
            print("No failure state. State machine finished.")
            return
        }
        
        proceed(next)
    }
    
    func proceed(next: State<ContextType>.Type) {
        do {
            current?.beforeExit()
            try current?.exit()
            let new = next.init(self)
            current = new
            new.beforeEnter()
            try new.enter()
        } catch {
            fail("unknwon error")
        }
    }
    
    func handle(event name: String) {
        do {
            try current?.handle(event: name)
        } catch StateError.UnhandledEvent {
            fail("unhandled '\(name)' event")
        } catch {
            fail("unknwon error while handling '\(name)' event")
        }
    }
}

class State<ContextType: ContextProtocol> {
    var machine: StateMachine<ContextType>
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
    
    func proceed(next: State.Type) {
        machine.proceed(next)
    }
    
    func fail(message: String) {
        machine.fail(message)
    }
    
    func handle(event name: String, error: NSError? = nil) throws {
        if let handler = eventHandlers[name] {
            handler()
        } else {
            throw StateError.UnhandledEvent
        }
    }
    
    func handle(event name: String, with function: () -> Void) {
        eventHandlers[name] = function
    }
}