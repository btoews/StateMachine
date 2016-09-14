//
//  StateMachineTest.swift
//  StateMachineTest
//
//  Created by Benjamin P Toews on 9/7/16.
//
//

import XCTest

class TestContext: StateMachineContext {
    var history = [String]()
    
    required init() {}
}

class TestStateMachine: StateMachine<TestContext> {
    override init() {
        super.init()
        context.history.append("tsm init")
        failure = TestStateOne.self
        proceed(TestStateOne.self)
    }
    
    override func reset() {
        context.history.append("tsm reset")
    }
}

class TestState: State<TestContext> {
    required init(_ m: StateMachine<TestContext>) {
        super.init(m)
    }
}

class TestStateOne: TestState {
    override func enter() {
        context.history.append("ts1 enter")
        
        handle(event: "testEvent",  with: testEventHandler)
        handle(event: "failEvent",  with: failEventHandler)
        handle(event: "resetEvent", with: resetEventHandler)
    }
    
    override func exit() {
        context.history.append("ts1 exit")
    }
    
    func testEventHandler() {
        context.history.append("ts1 testEvent")
        proceed(TestStateTwo.self)
    }
    
    func failEventHandler() {
        context.history.append("ts1 failEvent")
        fail("because of event")
    }
    
    func resetEventHandler() {
        machine.reset()
    }
}

class TestStateTwo: TestState {
    override func enter() {
        context.history.append("ts2 enter")
    }
    
    override func exit() {
        context.history.append("ts2 exit")
    }
}

class StateMachineTest: XCTestCase {
    func testTestStateMachineInit() {
//        let sm = TestStateMachine()
        let sm = TestStateMachine()
        XCTAssertEqual(["tsm init", "ts1 enter"], sm.context.history)
        
        sm.proceed(TestStateTwo.self)
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter"], sm.context.history)
        
        // failure state is initial state
        sm.fail("why not")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter"], sm.context.history)
        
        // handle expected event
        sm.handle(event: "testEvent")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter"], sm.context.history)
        
        // unexpected event goes to failure state
        sm.handle(event: "unexpected")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter"], sm.context.history)
        
        // Failure from handler
        sm.handle(event: "failEvent")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 failEvent", "ts1 exit", "ts1 enter"], sm.context.history)
        
        
        sm.handle(event: "resetEvent")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 failEvent", "ts1 exit", "ts1 enter", "tsm reset"], sm.context.history)
    }
}

