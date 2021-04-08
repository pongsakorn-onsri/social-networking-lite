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

protocol AuthenProtocol {
    var currentUser: User? { get set }
    
    func signUp(with email: String, password: String, completion: ((User?, Error?) -> Void)?)
    func signIn(with credential: AuthCredential, completion: ((User?, Error?) -> Void)?)
    func signIn(with email: String, password: String, completion: ((User?, Error?) -> Void)?)
    func signOut()
}

class Authen: NSObject, AuthenProtocol {
    
    private var auth: Auth
    var currentUser: User?
    
    init(auth: Auth) {
        self.auth = auth
    }
    
    func signUp(with email: String, password: String, completion: ((User?, Error?) -> Void)?) {
        auth.createUser(withEmail: email, password: password) { [weak self](authResult, error) in
            let user = User(firebaseUser: authResult?.user)
            self?.currentUser = user
            completion?(user, error)
        }
    }
    
    func signIn(with credential: AuthCredential, completion: ((User?, Error?) -> Void)?) {
        auth.signIn(with: credential) { [weak self](authResult, error) in
            let user = User(firebaseUser: authResult?.user)
            self?.currentUser = user
            completion?(user, error)
        }
    }
    
    func signIn(with email: String, password: String, completion: ((User?, Error?) -> Void)?) {
        auth.signIn(withEmail: email, password: password) { [weak self](authResult, error) in
            let user = User(firebaseUser: authResult?.user)
            self?.currentUser = user
            completion?(user, error)
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
        self.auth = Authen(auth: shared)
        let user = User(firebaseUser: shared.currentUser)
        userObservable = BehaviorRelay(value: user)
        currentUser = user
        super.init()
        shared.addStateDidChangeListener { (_, user) in
            self.currentUser = User(firebaseUser: user)
        }
    }
    
    init(auth: AuthenProtocol) {
        self.auth = auth
        userObservable = BehaviorRelay(value: auth.currentUser)
        currentUser = auth.currentUser
        super.init()
    }
}

extension UserManager {
    func signUp(with email: String, password: String) -> Single<User> {
        return Single.create { (observer) -> Disposable in
            self.auth.signUp(with: email, password: password) { (user, error) in
                if let user = user {
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
    
    func signIn(with credential: AuthCredential) -> Single<User> {
        return Single.create { (observer) -> Disposable in
            self.auth.signIn(with: credential) { (user, error) in
                if let user = user {
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
            self.auth.signIn(with: email, password: password) { (user, error) in
                if let user = user {
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
        currentUser = nil
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
