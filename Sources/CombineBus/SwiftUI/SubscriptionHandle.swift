import Foundation
import Combine

// Manages subscription lifecycle for SwiftUI views
internal class SubscriptionHandle: ObservableObject {
  var cancellables = Set<AnyCancellable>()
  
  func store(_ cancellable: AnyCancellable) {
    cancellables.insert(cancellable)
  }
  
  deinit {
    cancellables.forEach { $0.cancel() }
  }
}
