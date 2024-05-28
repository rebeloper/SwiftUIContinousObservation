
import SwiftUI

struct ContinousObservationModifier<T>: ViewModifier {
    
    init(_ value: T, perform: @escaping (T) -> ()) {
        withContinousObservation(of: value, perform: perform)
    }
    
    func body(content: Content) -> some View {
        content
    }
    
    func withContinousObservation(of value: @escaping @autoclosure () -> T, perform: @escaping (T) -> Void) {
        withObservationTracking {
            perform(value())
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
    ///   - perform: A closure to run when the value changes.
    /// - Returns: A view that fires an action when the specified value changes.
    func onObservedChange<T>(of value: T, perform: @escaping (T) -> ()) -> some View {
        self.modifier(ContinousObservationModifier(value, perform: perform))
    }
}
