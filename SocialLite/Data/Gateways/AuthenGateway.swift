//
//  AuthenGateway.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import FirebaseAuth
import RxSwift

struct AuthenGateway: AuthenGatewayType {
    
    var auth: Auth = Auth.auth()
    
    func signUp(dto: SignUpDto) -> Observable<User> {
        return Observable.create { (observer) -> Disposable in
            auth.createUser(withEmail: dto.email ?? "", password: dto.password ?? "") { (authResult, error) in
                if let user = User(firebaseUser: authResult?.user) {
                    observer.onNext(user)
                } else if let error = error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func signIn(dto: SignInDto) -> Observable<User> {
        return Observable.create { (observer) -> Disposable in
            auth.signIn(withEmail: dto.email ?? "", password: dto.password ?? "") { (authResult, error) in
                if let user = User(firebaseUser: authResult?.user) {
                    observer.onNext(user)
                } else if let error = error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func signIn(with credential: AuthCredential) -> Observable<User> {
        return Observable.create { (observer) -> Disposable in
            auth.signIn(with: credential) { (authResult, error) in
                if let user = User(firebaseUser: authResult?.user) {
                    observer.onNext(user)
                } else if let error = error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func signOut() -> Observable<Void> {
        do {
            try auth.signOut()
            return Observable.just(())
        } catch {
            return Observable.error(error)
        }
    }
}
