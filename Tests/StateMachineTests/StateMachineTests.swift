import XCTest
@testable import StateMachine

class TestContext: StateMachineContext {
    var history = [String]()
    
    required init() {}
}

enum TestStatus {
    case good
    case bad
}

class TestStateMachine: StateMachine<TestContext, TestStatus> {
    override init() {
        super.init()
        context.history.append("tsm init")
        failure = TestStateOne.self
    }
    
    override func reset() {
        context.history.append("tsm reset")
    }
}

class TestState: State<TestContext, TestStatus> {
    required init(_ m: MachineType) {
        super.init(m)
    }
}

class TestStateOne: TestState {
    override func enter() {
        context.history.append("ts1 enter")
        
        handles(event: "testEvent",  with: testEventHandler)
        handles(event: "failEvent",  with: failEventHandler)
        handles(event: "resetEvent", with: resetEventHandler)
    }
    
    override func exit() {
        context.history.append("ts1 exit")
        statusUpdate(.bad)
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
        statusUpdate(.good)
    }
}


class StateMachineTests: XCTestCase {
    func testTestStateMachineInit() {
        var statusHistory:[TestStatus] = []
        
        let sm = TestStateMachine()
        XCTAssertEqual(["tsm init"], sm.context.history)
        
        sm.subscribe() { status in
            statusHistory.append(status)
        }
        
        sm.proceed(TestStateOne.self)
        XCTAssertEqual(["tsm init", "ts1 enter"], sm.context.history)
        
        sm.proceed(TestStateTwo.self)
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter"], sm.context.history)
        XCTAssertEqual([TestStatus.bad], statusHistory)
        
        // failure state is initial state
        sm.fail("why not")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter"], sm.context.history)
        XCTAssertEqual([TestStatus.bad, TestStatus.good], statusHistory)
        
        // handle expected event
        sm.handle(event: "testEvent")
        XCTAssertEqual(["tsm init", "ts1 enter", "ts1 exit", "ts2 enter", "ts2 exit", "ts1 enter", "ts1 testEvent", "ts1 exit", "ts2 enter"], sm.context.history)
        XCTAssertEqual([TestStatus.bad, TestStatus.good, TestStatus.bad], statusHistory)
        
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
