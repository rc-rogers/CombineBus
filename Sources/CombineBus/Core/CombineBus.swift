import Foundation
import Combine

/// Type-safe event bus built on Combine
public class CombineBus: @unchecked Sendable {
  
  // MARK: - Properties
  
  /// Shared singleton instance
  public static let shared = CombineBus()
  
  /// The underlying Combine subject for all events
  private let subject = PassthroughSubject<Any, Never>()
  
  /// Active subscriptions
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - Initialization
  
  /// Create a new event bus instance
  public init() {
    // Allow creating custom instances for isolation
  }
  
  // MARK: - Public Methods
  
  /// Post an event to all subscribers
  /// - Parameter event: The event to post (any type)
  public func post<T>(_ event: T) {
    subject.send(event)
  }
  
  /// Subscribe to events on the main thread
  /// - Parameters:
  ///   - type: The event type to listen for
  ///   - handler: Closure called when event is received
  /// - Returns: Cancellable subscription
  @discardableResult
  public func onMainThread<T>(
    _ type: T.Type,
    handler: @escaping (T) -> Void
  ) -> AnyCancellable {
    return subject
      .compactMap { $0 as? T }
      .receive(on: DispatchQueue.main)
      .sink { event in
        handler(event)
      }
  }
  
  /// Subscribe to events on a background thread
  /// - Parameters:
  ///   - type: The event type to listen for
  ///   - qos: Quality of service for background queue
  ///   - handler: Closure called when event is received
  /// - Returns: Cancellable subscription
  @discardableResult
  public func onBackgroundThread<T>(
    _ type: T.Type,
    qos: DispatchQoS.QoSClass = .default,
    handler: @escaping (T) -> Void
  ) -> AnyCancellable {
    return subject
      .compactMap { $0 as? T }
      .receive(on: DispatchQueue.global(qos: qos))
      .sink { event in
        handler(event)
      }
  }
  
  /// Subscribe to events on the current thread
  /// - Parameters:
  ///   - type: The event type to listen for
  ///   - handler: Closure called when event is received
  /// - Returns: Cancellable subscription
  @discardableResult
  public func onReceive<T>(
    _ type: T.Type,
    handler: @escaping (T) -> Void
  ) -> AnyCancellable {
    return subject
      .compactMap { $0 as? T }
      .sink { event in
        handler(event)
      }
  }
}
