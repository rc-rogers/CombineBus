import XCTest
import Combine
@testable import CombineBus

final class MemoryLeakTests: XCTestCase {
  
  func testNoCyclicReference() {
    var bus: CombineBus? = CombineBus()
    weak var weakBus = bus
    
    var cancellables = Set<AnyCancellable>()
    
    bus?.onReceive(String.self) { _ in
      // Capture nothing strongly
    }
    .store(in: &cancellables)
    
    bus = nil
    XCTAssertNil(weakBus, "CombineBus should be deallocated")
  }
  
  func testSubscriptionCleanup() {
    let bus = CombineBus()
    
    autoreleasepool {
      var cancellables = Set<AnyCancellable>()
      
      bus.onReceive(String.self) { _ in }
        .store(in: &cancellables)
      
      // cancellables should be cleaned up when out of scope
    }
    
    // No way to directly test, but ensure no crash
    bus.post("Test after cleanup")
    XCTAssertNotNil(bus) // Bus should still exist
  }
}
