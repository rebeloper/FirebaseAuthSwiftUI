//
//  FirebaseAuthController.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

@Observable
final public class FirebaseAuthController: NSObject {
    
    public var authState: AuthState = .loading
    public var user: User?
    
    /// Presents the Sign in with Apple sheet
    /// - Parameter completion: completion with a `Result` containing the User object, the user is `nil` if it is not new
    func continueWithApple(completion: @escaping (Result<User?, Error>) -> ()) {
        authState = .authenticating
        
        self.onAuthentication = completion
        
        let nonce = SignInWithAppleUtils.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = SignInWithAppleUtils.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// Signs the user out
    public func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Internal
    
    var authStateHandler: AuthStateDidChangeListenerHandle?
    var onAuthentication: ((Result<User?, Error>) -> ())?
    var currentNonce: String?
    
    func startListeningToAuthChanges(path: String) {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if self.authState != .authenticating {
                self.authState = user != nil ? .authenticated : .notAuthenticated
            }
            if user != nil {
                FirebaseAuthUtils.isNewUserInFirestore(path: path, uid: user!.uid) { result in
                    switch result {
                    case .success(let isNew):
                        print("isNew: \(isNew)")
                        if !isNew {
                            self.authState = .authenticated
                        }
                        self.onAuthentication?(.success(isNew ? user : nil))
                    case .failure(let failure):
                        self.authState = .notAuthenticated
                        self.onAuthentication?(.failure(failure))
                    }
                }
            }
        }
    }
    
    func stopListeningToAuthChanges() {
        guard authStateHandler != nil else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }
    
}


