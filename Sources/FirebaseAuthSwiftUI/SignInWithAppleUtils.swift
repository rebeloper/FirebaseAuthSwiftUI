//
//  SignInWithAppleUtils.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

public struct SignInWithAppleUtils {
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    static func signInToFirebase(with token: SignInWithAppleToken, completion: @escaping  (Result<User?, Error>) -> ()) {
        
        let providerID = "apple.com"
        let idTokenString = token.idTokenString
        let nonce = token.nonce
        
        let credential = OAuthProvider.credential(withProviderID: providerID,
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        Auth.auth().signIn(with: credential) { (_, err) in
            if let err = err {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                completion(.failure(err))
                return
            }
            
            guard let user = Auth.auth().currentUser else {
                completion(.failure(SignInWithAppleError.noCurrentUser))
                return
            }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            let givenName = token.appleIDCredential.fullName?.givenName
            let middleName = token.appleIDCredential.fullName?.middleName
            let familyName = token.appleIDCredential.fullName?.familyName
            var displayName = "\(givenName != nil ? "\(givenName!) " : "")\(middleName != nil ? "\(middleName!) " : "")\(familyName != nil ? "\(familyName!)" : "")"
            print("name: \(displayName)")
            if displayName == "" {
                displayName = "Alex"
            }
            changeRequest?.displayName = displayName
            
            changeRequest?.commitChanges { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard Auth.auth().currentUser != nil else {
                    completion(.failure(SignInWithAppleError.noCurrentUser))
                    return
                }
                print("saved")
                completion(.success(nil))
            }
        }
    }
    
    static func createToken(from authorization: ASAuthorization, currentNonce: String?, completion:  ((Result<User?, Error>) -> ())?) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                completion?(.failure(SignInWithAppleError.noIdentityToken))
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                completion?(.failure(SignInWithAppleError.noTokenString))
                return
            }
            
            let token = SignInWithAppleToken(appleIDCredential: appleIDCredential, nonce: nonce, idTokenString: idTokenString)
            signInToFirebase(with: token) { result in
                switch result {
                case .success(_):
                    completion?(.success(nil))
                case .failure(let err):
                    completion?(.failure(err))
                }
            }
            
        } else {
            completion?(.failure(SignInWithAppleError.noAppleIdCredential))
        }
    }
}



