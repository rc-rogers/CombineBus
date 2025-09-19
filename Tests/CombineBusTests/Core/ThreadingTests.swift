import XCTest
import Combine
@testable import CombineBus

final class ThreadingTests: XCTestCase {
  
  var bus: CombineBus!
  var cancellables: Set<AnyCancellable>!
  
  override func setUp() {
    super.setUp()
    bus = CombineBus()
    cancellables = []
  }
  
  func testConcurrentPosts() {
    let expectation = XCTestExpectation(description: "All events received")
    expectation.expectedFulfillmentCount = 100
    
    bus.onReceive(NumberEvent.self) { _ in
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    let bus = self.bus!  // Capture bus before concurrent perform
    DispatchQueue.concurrentPerform(iterations: 100) { i in
      bus.post(NumberEvent(value: i))
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testThreadSafety() {
    let iterations = 1000
    let expectation = XCTestExpectation(description: "Thread safe")
    expectation.expectedFulfillmentCount = iterations
    
    var receivedCount = 0
    let lock = NSLock()
    
    bus.onReceive(NumberEvent.self) { _ in
      lock.lock()
      receivedCount += 1
      lock.unlock()
      expectation.fulfill()
    }
    .store(in: &cancellables)
    
    let group = DispatchGroup()
    
    let bus = self.bus!  // Capture bus before async
    for i in 0..<iterations {
      group.enter()
      DispatchQueue.global().async {
        bus.post(NumberEvent(value: i))
        group.leave()
      }
    }
    
    wait(for: [expectation], timeout: 10.0)
    XCTAssertEqual(receivedCount, iterations)
  }
}
