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
    
    /// Presents the Sign in with Apple sheet
    public func continueWithApple() async throws -> SignInWithAppleResult {
        let result = try await withCheckedThrowingContinuation({ continuation in
            continueWithApple { result in
                continuation.resume(with: result)
            }
        })
        return result
    }
    
    /// Signs the user out
    public func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Internal
    
    var authStateHandler: AuthStateDidChangeListenerHandle?
    var onContinueWithApple: ((Result<SignInWithAppleResult, Error>) -> ())?
    var currentNonce: String?
    
    func continueWithApple(completion: @escaping (Result<SignInWithAppleResult, Error>) -> ()) {
        authState = .authenticating
        
        self.onContinueWithApple = completion
        
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
    
    func startListeningToAuthChanges() {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            if self.authState != .authenticating {
                self.authState = user != nil ? .authenticated : .notAuthenticated
            }
        }
    }
    
    func stopListeningToAuthChanges() {
        guard authStateHandler != nil else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }
    
}


