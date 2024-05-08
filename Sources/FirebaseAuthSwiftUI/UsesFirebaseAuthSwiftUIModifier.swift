//
//  UsesFirebaseAuthSwiftUIModifier.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import FirebaseAuth

struct UsesFirebaseAuthSwiftUIModifier: ViewModifier {
    
    @State private var controller = FirebaseAuthController()
    
    private let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseAuth, controller)
            .onAppear {
                controller.startListeningToAuthChanges(path: path)
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
    }
}

public extension View {
    /// Sets up FirebaseAuthSwiftUI and gives access to a newly created `User`
    /// - Parameter firestoreUserCollectionPath: the collection path to the user document in Firestore
    /// - Parameter newUserResult: completion with a `Result` containing the User object, the user is `nil` if it is not new
    func usesFirebaseAuthSwiftUI(firestoreUserCollectionPath: String) -> some View {
        modifier(UsesFirebaseAuthSwiftUIModifier(path: firestoreUserCollectionPath))
    }
}

