//
//  OnNewUserCreatedModifier.swift
//  
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import FirebaseAuth

public struct OnNewUserCreatedModifier: ViewModifier {
    
    @Environment(\.firebaseAuth) private var firebaseAuth
    
    private let path: String
    private let newValue: (Result<User?, Error>) -> Void
    
    public init(path: String, newValue: @escaping (Result<User?, Error>) -> Void) {
        self.path = path
        self.newValue = newValue
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: firebaseAuth.user) { _, user in
                guard let user else { return }
                FirebaseAuthUtils.isNewUserInFirestore(path: "", uid: user.uid) { result in
                    switch result {
                    case .success(let isNew):
                        self.newValue(.success(isNew ? user : nil))
                    case .failure(let failure):
                        self.newValue(.failure(failure))
                    }
                }
            }
    }
}

public extension View {
    /// Listens to new a User creation with Firebase Auth
    /// - Parameter collectionPath: the collection path to the user document in Firestore
    /// - Parameter newValue: completion with the User object, returns `nil` if the user is not new
    func onNewUserCreated(collectionPath: String, newValue: @escaping (Result<User?, Error>) -> Void) -> some View {
        modifier(OnNewUserCreatedModifier(path: collectionPath, newValue: newValue))
    }
}
