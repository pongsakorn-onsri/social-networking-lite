//
//  SignUpUseCaseMock.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import RxSwift
import Dto
import FirebaseAuth

@testable import SocialLite
final class SignUpUseCaseMock: SignUpUseCaseType {
    typealias User = SocialLite.User
    
    var validateEmailCalled: Bool = false
    func validateEmail(_ email: String) -> ValidationResult {
        validateEmailCalled = true
        return SignUpDto.validateEmail(email).mapToVoid()
    }
    
    var validatePasswordCalled: Bool = false
    func validatePassword(_ password: String) -> ValidationResult {
        validatePasswordCalled = true
        return SignUpDto.validatePassword(password).mapToVoid()
    }
    
    var validateConfirmPasswordCalled: Bool = false
    func validateConfirmPassword(_ confirmPassword: String, _ password: String) -> ValidationResult {
        validateConfirmPasswordCalled = true
        return SignUpDto.validateConfirmPassword(confirmPassword, password).mapToVoid()
    }
    
    var signUpCalled: Bool = false
    func signUp(dto: SignUpDto) -> Observable<User> {
        signUpCalled = true
        let user = User(uid: dto.email ?? "", providerID: "test")
        return .just(user)
    }
}
