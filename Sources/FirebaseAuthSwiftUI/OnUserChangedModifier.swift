//
//  OnUserChangedModifier.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import FirebaseAuth

public struct OnUserChangedModifier: ViewModifier {
    
    @Environment(\.firebaseAuth) private var firebaseAuth
    public let newValue: (User) -> Void
    
    public init(_ newValue: @escaping (User) -> Void) {
        self.newValue = newValue
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: firebaseAuth.user) { _, newValue in
                guard let newValue else { return }
                self.newValue(newValue)
            }
    }
}

public extension View {
    /// Listens to User changes of Firebase Auth
    /// - Parameter newValue: completion with the User object
    func onUserChanged(_ newValue: @escaping (User) -> Void) -> some View {
        modifier(OnUserChangedModifier(newValue))
    }
}
