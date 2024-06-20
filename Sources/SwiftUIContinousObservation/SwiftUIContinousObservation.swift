
import SwiftUI

struct ContinousObservationModifier<T>: ViewModifier {
    
    init(_ value: T, perform: @escaping (T) async -> ()) {
        withContinousObservation(of: value, perform: perform)
    }
    
    func body(content: Content) -> some View {
        content
    }
    
    func withContinousObservation(of value: @escaping @autoclosure () -> T, perform: @escaping (T) async -> Void) {
        let _ = withObservationTracking {
            Task { @MainActor in
                await perform(value())
            }
        } onChange: {
            Task { @MainActor in
                withContinousObservation(of: value(), perform: perform)
            }
        }
    }
}

struct ContinousOptionalObservationModifier<T>: ViewModifier {
    
    init(_ value: T?, perform: @escaping (T?) async -> ()) {
        withContinousObservation(of: value, perform: perform)
    }
    
    func body(content: Content) -> some View {
        content
    }
    
    func withContinousObservation(of value: @escaping @autoclosure () -> T?, perform: @escaping (T?) async -> Void) {
        let _ = withObservationTracking {
            Task { @MainActor in
                await perform(value())
            }
        } onChange: {
            Task { @MainActor in
                withContinousObservation(of: value(), perform: perform)
            }
        }
    }
}

public extension View {
    /// Adds a modifier for this view that fires an action when a specific
    /// `@Observable` value changes.
    /// - Parameters:
    ///   - value: The value to check against when determining whether
    ///     to run the closure.
    ///   - perform: An async closure to run when the value changes.
    /// - Returns: A view that fires an action when the specified value changes.
    func onReceive<T>(of value: T, perform: @escaping (T) async -> ()) -> some View {
        self.modifier(ContinousObservationModifier(value, perform: perform))
    }
    
    /// Adds a modifier for this view that fires an action when a specific
    /// `@Observable` optional value changes.
    /// - Parameters:
    ///   - value: The optional value to check against when determining whether
    ///     to run the closure.
    ///   - perform: An async closure to run when the optional value changes.
    /// - Returns: A view that fires an action when the specified optional value changes.
    func onReceive<T>(of value: T?, perform: @escaping (T?) async -> ()) -> some View {
        self.modifier(ContinousOptionalObservationModifier(value, perform: perform))
    }
}
