//
//  State.swift
//  StateMachine
//
//  Created by Benjamin P Toews on 9/14/16.
//
//

import Foundation

class State<ContextType: StateMachineContext, StatusType> {
    typealias MachineType  = StateMachine<ContextType, StatusType>
    typealias EventHandler = () -> Void
    
    let machine: MachineType
    var eventHandlers: [String:EventHandler] = [:]
    var context: ContextType { return machine.context }
    
    required init(_ m: MachineType) {
        machine = m
    }
    
    // Callback when entering state.
    func enter() {}
 
    // Callback when exiting state.
    func exit() {}
    
    // Go to the next state.
    func proceed(_ next: State.Type) {
        machine.proceed(next)
    }
    
    // Go to failure state.
    func fail(_ message: String) {
        machine.fail(message)
    }
    
    // Notify machine subscribers about a status update.
    func statusUpdate(_ status: StatusType) {
        machine.statusUpdate(status)
    }
    
    // Register an event handler.
    func handles(event name: String, with function: @escaping EventHandler) {
        eventHandlers[name] = function
    }
}
