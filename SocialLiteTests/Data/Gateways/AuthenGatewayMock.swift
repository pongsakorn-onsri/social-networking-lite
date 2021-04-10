//
//  MockAuthen.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 4/4/2564 BE.
//

import Foundation
import FirebaseAuth
import RxSwift

@testable import SocialLite
class AuthenGatewayMock: NSObject, AuthenGatewayType {
    
    typealias User = SocialLite.User
    var currentUser: User?
    
    var getUserCalled = false
    func getUser() -> Observable<User> {
        let user = User(uid: "", providerID: "")
        getUserCalled = true
        return Observable.just(currentUser ?? user)
    }
    
    var signUpCalled = false
    func signUp(dto: SignUpDto) -> Observable<User> {
        let user = User(uid: dto.email ?? "", providerID: "test")
        currentUser = user
        signUpCalled = true
        return Observable.just(user)
    }
    
    var signInCalled = false
    func signIn(dto: SignInDto) -> Observable<User> {
        let user = User(uid: "", providerID: "test")
        currentUser = user
        signInCalled = true
        return Observable.just(user)
    }
    
    var signInCredentialCalled = false
    func signIn(with credential: AuthCredential) -> Observable<User> {
        let user = User(uid: "", providerID: credential.provider)
        currentUser = user
        signInCredentialCalled = true
        return Observable.just(user)
    }
    
    var signOutCalled = false
    func signOut() -> Observable<Void> {
        currentUser = nil
        signOutCalled = true
        return Observable.just(())
    }
    
}
