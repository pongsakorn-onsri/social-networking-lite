//
//  UserManager.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

typealias User = Firebase.User

protocol AuthenProtocol {
    var currentUser: User? { get set }
    
    func signIn(with credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signIn(with email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?)
    func signOut()
}

class Authen: NSObject, AuthenProtocol {
    
    private var auth: Auth
    var currentUser: User?
    
    init(auth: Auth) {
        self.auth = auth
    }
    
    func signIn(with credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?) {
        auth.signIn(with: credential) { [weak self](authResult, error) in
            completion?(authResult, error)
            self?.currentUser = authResult?.user
        }
    }
    
    func signIn(with email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        auth.signIn(withEmail: email, password: password) { [weak self](authResult, error) in
            completion?(authResult, error)
            self?.currentUser = authResult?.user
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            currentUser = nil
        } catch {
            print("Sign out action error: \(error.localizedDescription)")
        }
    }
}

final class UserManager: NSObject {
    static var shared = UserManager()
    
    private var auth: AuthenProtocol
    var userObservable: BehaviorRelay<User?>
    var isSignIn: Bool { currentUser != nil }
    var currentUser: User? {
        didSet {
            userObservable.accept(currentUser)
        }
    }
    
    private override init() {
        let shared = Auth.auth()
        auth = Authen(auth: shared)
        userObservable = BehaviorRelay(value: shared.currentUser)
        currentUser = shared.currentUser
        super.init()
        shared.addStateDidChangeListener { (_, user) in
            self.currentUser = user
        }
    }
}

extension UserManager {
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
    
    func signIn(with email: String, password: String) -> Single<User> {
        return Single.create { (observer) -> Disposable in
            self.auth.signIn(with: email, password: password) { (authResult, error) in
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

enum SignInError: LocalizedError {
    case unknown
    case message(String)
    
    var errorDescription: String? {
        switch self {
        case .unknown: return "Something wrong ❌"
        case let .message(text): return text
        }
    }
}
