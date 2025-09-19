import Foundation

// Thread execution options for event delivery
public enum ThreadType {
  case main
  case background(qos: DispatchQoS.QoSClass = .default)
  case current // Deliver on current thread
  
  var queue: DispatchQueue? {
    switch self {
    case .main:
      return DispatchQueue.main
    case .background(let qos):
      return DispatchQueue.global(qos: qos)
    case .current:
      return nil // Use current thread
    }
  }
}
