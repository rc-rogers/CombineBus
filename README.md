# CombineBus

Type-safe event bus for Swift, built on Combine. A modern replacement for NotificationCenter.

## Features

- ✅ **Type-safe** - No more string-based event names or dictionary casting
- ✅ **Thread-safe** - Built on Combine's robust infrastructure  
- ✅ **Memory-safe** - Automatic cleanup with AnyCancellable
- ✅ **Simple API** - Post and subscribe with minimal code
- ✅ **SwiftUI Ready** - First-class support for SwiftUI lifecycle
- ✅ **Lightweight** - ~150 lines of focused code
- ✅ **Zero Dependencies** - Uses only Apple's Combine framework

## Requirements

- iOS 17.0+ / macOS 15.0+ / tvOS 17.0+ / watchOS 10.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add CombineBus to your project through Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/rc-rogers/CombineBus.git`
3. Click Add Package

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/rc-rogers/CombineBus.git", from: "1.0.0")
]
```

## Usage

### Basic Example

```swift
import CombineBus

// Define your events as simple structs
struct UserLoggedInEvent {
    let userId: String
    let timestamp: Date
}

// Post events from anywhere
let bus = CombineBus.shared
bus.post(UserLoggedInEvent(userId: "123", timestamp: .now))

// Subscribe to events
let cancellable = bus.onMainThread(UserLoggedInEvent.self) { event in
    print("User logged in: \(event.userId)")
}
```

### SwiftUI Integration

```swift
import SwiftUI
import CombineBus

struct ContentView: View {
    @State private var message = "Waiting..."
    
    var body: some View {
        Text(message)
            .onCombineBus(UserLoggedInEvent.self) { event in
                message = "User \(event.userId) logged in"
            }
    }
}
```

### Thread Control

```swift
// Subscribe on main thread (for UI updates)
CombineBus.shared.onMainThread(DataEvent.self) { event in
    // Update UI safely
}

// Subscribe on background thread (for heavy work)
CombineBus.shared.onBackgroundThread(DataEvent.self) { event in
    // Perform intensive operations
}

// Subscribe on current thread
CombineBus.shared.onReceive(DataEvent.self) { event in
    // Runs on whatever thread posted the event
}
```

## Why CombineBus?

### Before (NotificationCenter)
```swift
// Posting
NotificationCenter.default.post(
    name: Notification.Name("UserLoggedIn"),
    object: nil,
    userInfo: ["userId": userId]
)

// Subscribing (verbose!)
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleUserLogin(_:)),
    name: Notification.Name("UserLoggedIn"),
    object: nil
)

// Handling (unsafe casting)
@objc func handleUserLogin(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let userId = userInfo["userId"] as? String else { return }
    // Finally ready to use
}

// Must remember to cleanup!
deinit {
    NotificationCenter.default.removeObserver(self)
}
```

### After (CombineBus)
```swift
// Posting
CombineBus.shared.post(UserLoggedInEvent(userId: userId))

// Subscribing & handling (simple!)
CombineBus.shared.onMainThread(UserLoggedInEvent.self) { event in
    print(event.userId) // Direct access, no casting!
}
// Automatic cleanup!
```

## Advanced Usage

### Using with Dependency Injection

CombineBus works with any DI system:

```swift
// Step 1: Register with your DI container (e.g., in AppDelegate)
container.register(CombineBus.shared)

// Step 2: Use in your ViewModels/Services
class AuthService {
    @Inject private var bus: CombineBus
    
    func login() {
        // ... login logic ...
        bus.post(UserLoggedInEvent(userId: "123"))
    }
}

// Step 3: Use in SwiftUI Views
struct ProfileView: View {
    @Inject private var bus: CombineBus
    @State private var username = "Guest"
    
    var body: some View {
        Text("Hello, \(username)")
            .onCombineBus(UserLoggedInEvent.self, bus: bus) { event in
                username = "User \(event.userId)"
            }
    }
}
```

Note: `@Inject` is a placeholder for your DI property wrapper (e.g., `@AppInject`, `@Injected`, etc.)

### Custom Event Bus Instances

```swift
// Create isolated event buses for different modules
let authEventBus = CombineBus()
let dataEventBus = CombineBus()
```

### SwiftUI Thread Control

```swift
struct ContentView: View {
    @State private var data = ""
    
    var body: some View {
        Text(data)
            // Process on background thread
            .onCombineBus(
                HeavyDataEvent.self, 
                thread: .backgroundThread
            ) { event in
                // Perform heavy computation
                let processed = processData(event.data)
                DispatchQueue.main.async {
                    data = processed
                }
            }
            // UI updates on main thread (default)
            .onCombineBus(UIUpdateEvent.self) { event in
                data = event.message // Safe on main thread
            }
    }
}
```

## Event Design Tips

Events can be any type - structs, classes, enums, or even primitive types:

```swift
// Simple struct events (recommended)
struct OrderPlaced {
    let orderId: String
    let amount: Decimal
}

// Enum events for state
enum ConnectionState {
    case connected
    case disconnected
    case error(Error)
}

// Even simple types work
CombineBus.shared.post("simple_string_event")
CombineBus.shared.post(42)

// But structs provide better type safety and clarity
```

## Testing

```swift
import XCTest
import CombineBus

class MyTests: XCTestCase {
    var bus: CombineBus!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Use isolated bus for testing
        bus = CombineBus()
        cancellables = []
    }
    
    func testEventDelivery() {
        let expectation = XCTestExpectation(description: "Event received")
        
        bus.onReceive(TestEvent.self) { event in
            XCTAssertEqual(event.value, 42)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        bus.post(TestEvent(value: 42))
        
        wait(for: [expectation], timeout: 1.0)
    }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

CombineBus is available under the MIT license. See the LICENSE file for more info.

## Author

Created by [rc-rogers](https://github.com/rc-rogers)

---

## Support

For questions, issues, or suggestions, please [open an issue](https://github.com/rc-rogers/CombineBus/issues).

---

Made with ❤️ using Swift and Combine
