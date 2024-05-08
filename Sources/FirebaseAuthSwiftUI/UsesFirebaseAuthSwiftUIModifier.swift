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
    private let newValue: ((Result<User?, Error>, FirebaseAuthController)) -> Void
    
    public init(path: String, newValue: @escaping ((Result<User?, Error>, FirebaseAuthController)) -> Void) {
        self.path = path
        self.newValue = newValue
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseAuth, controller)
            .onAppear {
                controller.startListeningToAuthChanges()
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
            .onNewUserCreated(collectionPath: path, newValue: newValue)
    }
}

public extension View {
    /// Sets up FirebaseAuthSwiftUI and gives access to a newly created `User`
    /// - Parameter firestoreUserCollectionPath: the collection path to the user document in Firestore
    /// - Parameter newUserResult: completion with a `Result` containing the User object, the user is `nil` if it is not new
    func usesFirebaseAuthSwiftUI(firestoreUserCollectionPath: String, newUserResult: @escaping ((Result<User?, Error>, FirebaseAuthController)) -> Void) -> some View {
        modifier(UsesFirebaseAuthSwiftUIModifier(path: firestoreUserCollectionPath, newValue: newUserResult))
    }
}

