//
//  UserManager.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import Firebase
import RxSwift

protocol AuthenProtocol {
    var currentUser: Firebase.User? { get }
    
    func signIn(with credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signOut()
}

class Authen: NSObject, AuthenProtocol {
    
    private var auth: Auth
    
    var currentUser: Firebase.User? { auth.currentUser }
    
    init(auth: Auth) {
        self.auth = auth
    }
    
    func signIn(with credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?) {
        auth.signIn(with: credential, completion: completion)
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch {
            print("Sign out action error: \(error.localizedDescription)")
        }
    }
}

final class UserManager: NSObject {
    static var shared = UserManager()
    
    private var auth: AuthenProtocol
    
    private override init() {
        auth = Authen(auth: Auth.auth())
    }
    
    var user: Firebase.User? { auth.currentUser }
    var isSignIn: Bool { user != nil }
    
    func signIn(with credential: AuthCredential) -> Single<User> {
        return Single.create { (observer) -> Disposable in
            self.auth.signIn(with: credential) { (authResult, error) in
                if let user = authResult?.user {
                    observer(.success(user))
                } else if let error = error {
                    observer(.error(error))
                } else {
                    observer(.error(SignInError.unknown))
                }
                
            }
            return Disposables.create()
        }
    }
    
    func signOut() {
        auth.signOut()
    }
}

enum SignInError: Error, CustomStringConvertible {
    case unknown
    
    var description: String {
        switch self {
        case .unknown: return "Something wrong ❌"
        }
    }
}
