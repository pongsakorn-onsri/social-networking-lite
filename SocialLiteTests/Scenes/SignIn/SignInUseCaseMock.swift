//
//  SignInUseCaseMock.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import RxSwift
import Dto
import FirebaseAuth

@testable import SocialLite
final class SignInUseCaseMock: SignInUseCaseType {
    typealias User = SocialLite.User
    
    var validateEmailCalled: Bool = false
    func validateEmail(_ email: String) -> ValidationResult {
        validateEmailCalled = true
        return SignInDto.validateEmail(email).mapToVoid()
    }
    
    var validatePasswordCalled: Bool = false
    func validatePassword(_ password: String) -> ValidationResult {
        validatePasswordCalled = true
        return SignInDto.validatePassword(password).mapToVoid()
    }
    
    var signInCalled: Bool = false
    func signIn(dto: SignInDto) -> Observable<User> {
        signInCalled = true
        let user = User(uid: dto.email ?? "", providerID: "test")
        return Observable.just(user)
    }
    
    var signInCredential: Bool = false
    func signIn(with credential: AuthCredential) -> Observable<User> {
        signInCredential = true
        let user = User(uid: "", providerID: credential.provider)
        return Observable.just(user)
    }
}
