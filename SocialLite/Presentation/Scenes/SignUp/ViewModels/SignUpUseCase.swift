//
//  SignUpUseCase.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import Foundation
import Resolver
import RxSwift
import Dto

protocol SignUpUseCaseType {
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func validateConfirmPassword(_ confirmPassword: String, _ password: String) -> ValidationResult
    
    func signUp(with email: String, password: String) -> Observable<User>
}

struct SignUpUseCase: SignUpUseCaseType, SigningUp {
    @Injected var authenGateway: AuthenGatewayType
    
    func signUp(with email: String, password: String) -> Observable<User> {
        let dto = SignUpDto(email: email, password: password, confirmPassword: password)
        return authenGateway.signUp(dto: dto)
    }
}
