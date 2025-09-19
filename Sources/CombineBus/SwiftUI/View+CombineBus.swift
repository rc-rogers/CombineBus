import SwiftUI
import Combine

// SwiftUI View extension for easy event subscription
extension View {
  
  /// Subscribe to CombineBus events
  /// - Parameters:
  ///   - type: The event type to listen for
  ///   - bus: The event bus instance (defaults to shared)
  ///   - thread: Thread to receive events on (defaults to main)
  ///   - handler: Closure called when event is received
  /// - Returns: Modified view
  public func onCombineBus<T>(
    _ type: T.Type,
    bus: CombineBus = .shared,
    thread: ThreadType = .mainThread,
    handler: @escaping (T) -> Void
  ) -> some View {
    self.modifier(
      CombineBusViewModifier(
        bus: bus,
        eventType: type,
        thread: thread,
        handler: handler
      )
    )
  }
}

// Make ThreadType public for SwiftUI API
extension ThreadType {
  public static var mainThread: ThreadType { .main }
  public static var backgroundThread: ThreadType { .background() }
  public static var currentThread: ThreadType { .current }
}
