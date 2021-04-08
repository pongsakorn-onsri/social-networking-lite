//
//  SigningIn.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseAuth
import Dto
import ValidatedPropertyKit

protocol SigningIn {
    var authenGateway: AuthenGatewayType { get }
}

extension SigningIn {
    func signIn(dto: SignInDto) -> Observable<User> {
        if let error = dto.validationError {
            return Observable.error(error)
        }
        return authenGateway.signIn(dto: dto)
    }
    
    func signIn(with credential: AuthCredential) -> Observable<User> {
        authenGateway.signIn(with: credential)
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        SignInDto.validateEmail(email).mapToVoid()
    }
    func validatePassword(_ password: String) -> ValidationResult {
        SignInDto.validatePassword(password).mapToVoid()
    }
}
