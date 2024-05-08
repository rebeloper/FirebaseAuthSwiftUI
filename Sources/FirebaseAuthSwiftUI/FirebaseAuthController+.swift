//
//  FirebaseAuthController+.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import AuthenticationServices

extension FirebaseAuthController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerDelegate
    
    @MainActor
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        SignInWithAppleUtils.createToken(from: authorization, currentNonce: currentNonce, completion: onAuthentication)
    }
    
    @MainActor
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authState = .notAuthenticated
        onAuthentication?(.failure(error))
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
#if os(iOS)
    public var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window!
    }
#endif
    
#if os(macOS)
    public var window: NSWindow? {
        guard let window = NSApplication.shared.keyWindow else {
            return nil
        }
        return window
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window!
    }
#endif
}
