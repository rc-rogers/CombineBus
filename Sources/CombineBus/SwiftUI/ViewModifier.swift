import SwiftUI
import Combine

// SwiftUI view modifier for event subscriptions
internal struct CombineBusViewModifier<Event>: ViewModifier {
  let bus: CombineBus
  let eventType: Event.Type
  let thread: ThreadType
  let handler: (Event) -> Void
  
  @StateObject private var handle = SubscriptionHandle()
  
  func body(content: Content) -> some View {
    content
      .onAppear {
        let cancellable: AnyCancellable
        
        switch thread {
        case .main:
          cancellable = bus.onMainThread(eventType, handler: handler)
        case .background(let qos):
          cancellable = bus.onBackgroundThread(
            eventType,
            qos: qos,
            handler: handler
          )
        case .current:
          cancellable = bus.onReceive(eventType, handler: handler)
        }
        
        handle.store(cancellable)
      }
  }
}
