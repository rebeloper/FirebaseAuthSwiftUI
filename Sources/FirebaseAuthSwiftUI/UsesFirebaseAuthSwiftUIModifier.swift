//
//  UsesFirebaseAuthSwiftUIModifier.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

struct UsesFirebaseAuthSwiftUIModifier: ViewModifier {
    
    @State private var controller = FirebaseAuthController()
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseAuth, controller)
            .onAppear {
                controller.startListeningToAuthChanges()
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
    }
}

public extension View {
    /// Sets up FirebaseAuthSwiftUI
    func usesFirebaseAuthSwiftUI() -> some View {
        modifier(UsesFirebaseAuthSwiftUIModifier())
    }
}

