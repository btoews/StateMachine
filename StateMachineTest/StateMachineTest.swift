//
//  StateMachineTest.swift
//  StateMachineTest
//
//  Created by Benjamin P Toews on 9/7/16.
//
//

import XCTest

class TestContext: ContextProtocol {
    var history = [String]()
    
    required init() {}
}

class TestStateMachine: StateMachine<TestContext> {
    override init() {
        super.init()
        context.history.append("tsm init")
        let initial = TestStateOne(self)
        self.failure = initial
        proceed(to: initial)
    }
}

class TestState: State<TestContext> {
    override init(_ m: StateMachine<TestContext>) {
        super.init(m)
    }
}

class TestStateOne: TestState {
    override func enter() {
        context.history.append("ts1 enter")
        
        handle(event: "testEvent", with: testEventHandler)
    }
    
    override func exit() {
        context.history.append("ts1 exit")
    }
    
    func testEventHandler(error: NSError?) {
        context.history.append("ts1 testEvent")
        machine.proceed(to: TestStateTwo(machine))
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
        let sm = TestStateMachine()
        XCTAssertEqual(["tsm init", "ts1 enter"], sm.context.history)
        
        sm.proceed(to: TestStateTwo(sm))
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter"], sm.context.history)
        
        // failure state is initial state
        sm.fail(because: "why not")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter"], sm.context.history)
        
        // handle expected event
        sm.handle(event: "testEvent")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter"], sm.context.history)
        
        // unexpected event goes to failure state
        sm.handle(event: "unexpected")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter"], sm.context.history)
    }
}

