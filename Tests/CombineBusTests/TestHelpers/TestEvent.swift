import Foundation

// Test events
struct TestEvent: Equatable {
  let id: UUID = UUID()
  let message: String
}

struct NumberEvent: Equatable {
  let value: Int
}
