//
//  SigningUp.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import Dto
import RxSwift
import ValidatedPropertyKit

struct SignUpDto: Dto {
    
    @Validated(.nonEmpty("Please input your email address.") && .isEmail("Your email address incorrect format."))
    var email: String? = ""
    
    @Validated(.nonEmpty("Please input your password.") && .minLength(min: 8, message: "Password is too short"))
    var password: String? = ""
    
    @Validated(.nonEmpty("Please input your confirm password.") &&
                .minLength(min: 8, message: "Password is too short"))
    var confirmPassword: String? = ""
    
    var validatedProperties: [ValidatedProperty] {
        return [_email, _password, _confirmPassword]
    }
}

extension SignUpDto {
    init(email: String, password: String, confirmPassword: String) {
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
    }
    
    static func validateUserName(_ email: String) -> Result<String, ValidationError> {
        SignUpDto()._email.isValid(value: email)
    }
    
    static func validatePassword(_ password: String) -> Result<String, ValidationError> {
        SignUpDto()._password.isValid(value: password)
    }
    
    static func validateConfirmPassword(_ password: String) -> Result<String, ValidationError> {
        SignUpDto()._confirmPassword.isValid(value: password)
            .flatMap { (confirmPassword) -> Result<String, ValidationError> in
                if SignUpDto()._password.wrappedValue == confirmPassword {
                    return .success(confirmPassword)
                } else {
                    return .failure(ValidationError(message: "Confirm password should be match password"))
                }
            }
    }
}


protocol SigningUp {
    var authenGateway: AuthenGatewayType { get }
}

extension SigningUp {
    func signUp(dto: SignUpDto) -> Observable<User> {
        
        if let error = dto.validationError {
            return Observable.error(error)
        }
        
        return authenGateway.signUp(dto: dto)
    }
}
