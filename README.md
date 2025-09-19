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

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Xcode 12.0+
- Swift 5.3+

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
let eventBus = EventBus.shared
eventBus.post(UserLoggedInEvent(userId: "123", timestamp: .now))

// Subscribe to events
let cancellable = eventBus.onMainThread(UserLoggedInEvent.self) { event in
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
            .onEvent(UserLoggedInEvent.self) { event in
                message = "User \(event.userId) logged in"
            }
    }
}
```

### Thread Control

```swift
// Subscribe on main thread (for UI updates)
eventBus.onMainThread(DataEvent.self) { event in
    // Update UI safely
}

// Subscribe on background thread (for heavy work)
eventBus.onBackgroundThread(DataEvent.self) { event in
    // Perform intensive operations
}

// Subscribe on current thread
eventBus.onReceive(DataEvent.self) { event in
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
eventBus.post(UserLoggedInEvent(userId: userId))

// Subscribing & handling (simple!)
eventBus.onMainThread(UserLoggedInEvent.self) { event in
    print(event.userId) // Direct access, no casting!
}
// Automatic cleanup!
```

## Advanced Usage

### Using with Dependency Injection

CombineBus works with any DI system:

```swift
// Step 1: Register with your DI container (e.g., in AppDelegate)
container.register(EventBus.shared)

// Step 2: Use in your ViewModels/Services
class AuthService {
    @Inject private var eventBus: EventBus
    
    func login() {
        // ... login logic ...
        eventBus.post(UserLoggedInEvent(userId: "123"))
    }
}

// Step 3: Use in SwiftUI Views
struct ProfileView: View {
    @Inject private var eventBus: EventBus
    @State private var username = "Guest"
    
    var body: some View {
        Text("Hello, \(username)")
            .onEvent(UserLoggedInEvent.self, eventBus: eventBus) { event in
                username = "User \(event.userId)"
            }
    }
}
```

Note: `@Inject` is a placeholder for your DI property wrapper (e.g., `@AppInject`, `@Injected`, etc.)

### Custom Event Bus Instances

```swift
// Create isolated event buses for different modules
let authEventBus = EventBus()
let dataEventBus = EventBus()
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

CombineBus is available under the MIT license. See the LICENSE file for more info.

## Author

Created by [RC Rogers](https://github.com/rc-rogers)

---

## Status

🚧 **Under Development** - Core functionality complete, documentation in progress.

## Roadmap

- [x] Core event bus implementation
- [x] Thread control (main/background)
- [x] SwiftUI integration
- [ ] Comprehensive test suite
- [ ] Performance benchmarks
- [ ] Example app
- [ ] CocoaPods support (if requested)

## Support

For questions, issues, or suggestions, please [open an issue](https://github.com/rc-rogers/CombineBus/issues).

---

Made with ❤️ using Swift and Combine
