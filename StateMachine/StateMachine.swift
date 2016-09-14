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
    var logger:LoggerProtocol? { get set }
    
    init()
    init(logger:LoggerProtocol?)
}

extension ContextProtocol {
    init(logger l:LoggerProtocol?) {
        self.init()
        logger = l ?? PrintLogger()
    }
    
    func log(msg:String)   { logger?.log(msg)   }
    func warn(msg:String)  { logger?.warn(msg)  }
    func debug(msg:String) { logger?.debug(msg) }
}

class StateMachine<ContextType: ContextProtocol>: NSObject {
    var current: State<ContextType>?
    var failure: State<ContextType>.Type?
    var context: ContextType
    
    init(logger:LoggerProtocol? = nil) {
        context = ContextType(logger: logger)
        super.init()
    }

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
        context.debug("Failing at \(currentName) because \(message)")
        
        guard let next = failure else {
            context.debug("No failure state. State machine finished.")
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

class State<ContextType: ContextProtocol> {
    let machine: StateMachine<ContextType>
    var eventHandlers: [String:() -> Void] = [:]
    var context: ContextType { return machine.context }
    
    required init(_ m: StateMachine<ContextType>) {
        machine = m
    }
    
    // Debugging callback.
    func beforeEnter() {
        context.debug("Entering \(self)")
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