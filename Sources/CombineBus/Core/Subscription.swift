import Foundation
import Combine

// Internal subscription information
internal struct Subscription {
  let id: UUID = UUID()
  let eventType: String
  let threadType: ThreadType
  let cancellable: AnyCancellable
  
  init(
    eventType: String,
    threadType: ThreadType,
    cancellable: AnyCancellable
  ) {
    self.eventType = eventType
    self.threadType = threadType
    self.cancellable = cancellable
  }
}
