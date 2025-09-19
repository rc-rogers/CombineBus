import XCTest
import Combine
@testable import CombineBus

final class CombineBusTests: XCTestCase {
  
  var bus: CombineBus!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    bus = CombineBus()
    cancellables = []
  }
  
  override func tearDown() {
    cancellables = nil
    bus = nil
    super.tearDown()
  }
  
  func testPostAndReceive() {
    let expectation = XCTestExpectation(description: "Event received")
    let testEvent = TestEvent(message: "Hello")
    
    bus.onReceive(TestEvent.self) { event in
      XCTAssertEqual(event.message, "Hello")
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    bus.post(testEvent)
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testTypeFiltering() {
    let stringExpectation = XCTestExpectation(description: "String received")
    let numberExpectation = XCTestExpectation(description: "Number received")
    numberExpectation.isInverted = true // Should NOT be called
    
    bus.onReceive(String.self) { string in
      XCTAssertEqual(string, "Test")
      stringExpectation.fulfill()
    }
    .store(in: &cancellables)
    
    bus.onReceive(NumberEvent.self) { _ in
      numberExpectation.fulfill()
    }
    .store(in: &cancellables)
    
    bus.post("Test")
    
    wait(for: [stringExpectation, numberExpectation], timeout: 1.0)
  }
  
  func testMainThreadDelivery() {
    let expectation = XCTestExpectation(description: "Main thread")
    
    bus.onMainThread(TestEvent.self) { _ in
      XCTAssertTrue(Thread.isMainThread)
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    let bus = self.bus!  // Capture bus before async
    DispatchQueue.global().async {
      bus.post(TestEvent(message: "Background"))
    }
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testBackgroundThreadDelivery() {
    let expectation = XCTestExpectation(description: "Background thread")
    
    bus.onBackgroundThread(TestEvent.self) { _ in
      XCTAssertFalse(Thread.isMainThread)
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    bus.post(TestEvent(message: "Main"))
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testMultipleSubscribers() {
    let expectation1 = XCTestExpectation(description: "Subscriber 1")
    let expectation2 = XCTestExpectation(description: "Subscriber 2")
    
    bus.onReceive(TestEvent.self) { _ in
      expectation1.fulfill()
    }
    .store(in: &cancellables)
    
    bus.onReceive(TestEvent.self) { _ in
      expectation2.fulfill()
    }
    .store(in: &cancellables)
    
    bus.post(TestEvent(message: "Broadcast"))
    
    wait(for: [expectation1, expectation2], timeout: 1.0)
  }
  
  func testCancellation() {
    let expectation = XCTestExpectation(description: "Should not receive")
    expectation.isInverted = true
    
    let cancellable = bus.onReceive(TestEvent.self) { _ in
      expectation.fulfill()
    }
    
    cancellable.cancel()
    bus.post(TestEvent(message: "Cancelled"))
    
    wait(for: [expectation], timeout: 1.0)
  }
}
