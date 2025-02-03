//
//  FirebaseAuthController.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

@Observable
final public class FirebaseAuthController: NSObject {
    
    public var state: AuthState = .loading
    public var user: User?
    
    /// Presents the Sign in with Apple sheet
    /// 
    /// - Parameter options: what should the Profile in Firestore contain upon sign up
    /// - Parameter completion: completion with an optional `Error`
    public func continueWithApple(options: [FirestoreProfileOption] = [], completion: ((Error?) -> Void)? = nil) {
        state = .authenticating
        self.onAuthentication = completion
        self.profileOptions = options
        
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
    var onAuthentication: ((Error?) -> ())?
    var currentNonce: String?
    var profileOptions: [FirestoreProfileOption] = []
    
    func startListeningToAuthChanges(path: String) {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if self.state != .authenticating {
                self.state = user != nil ? .authenticated : .notAuthenticated
            }
            if user != nil {
                FirebaseAuthUtils.isNewUserInFirestore(path: path, uid: user!.uid) { result in
                    switch result {
                    case .success(let isNew):
                        if !isNew {
                            self.state = .authenticated
                        } else {
                            self.saveProfile(user!, path: path, options: self.profileOptions) { error in
                                if let error {
                                    self.state = .notAuthenticated
                                    self.onAuthentication?(error)
                                    return
                                }
                                self.state = .authenticated
                            }
                        }
                    case .failure(let error):
                        self.state = .notAuthenticated
                        self.onAuthentication?(error)
                    }
                }
            }
        }
    }
    
    func stopListeningToAuthChanges() {
        guard authStateHandler != nil else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }
    
    func saveProfile(_ user: User, path: String, options: [FirestoreProfileOption], completion: ((Error?) -> Void)?) {
        let reference = Firestore.firestore().collection(path).document(user.uid)
        
        var data: [String: Any] = [:]
        if options.isEmpty {
            data["uid"] = user.uid
            data["displayName"] = user.displayName ?? ""
        } else {
            for option in options {
                switch option {
                case .uid:
                    data["uid"] = user.uid
                case .email:
                    data["email"] = user.email ?? ""
                case .displayName:
                    data["displayName"] = user.displayName ?? ""
                case .photoURL:
                    data["photoURL"] = user.photoURL?.absoluteString ?? ""
                }
            }
        }
        
        reference.setData(data, completion: completion)
    }
}
