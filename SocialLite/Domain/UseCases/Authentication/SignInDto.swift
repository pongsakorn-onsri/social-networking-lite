//
//  SignInDto.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import Dto
import ValidatedPropertyKit

struct SignInDto: Dto {
    @Validated(.nonEmpty("Please input email account.") && .isEmail("Not valid email format."))
    var email: String? = ""
    
    @Validated(.nonEmpty("Please input your password.") && .minLength(min: 8, message: "Password is too short"))
    var password: String? = ""
    
    var validatedProperties: [ValidatedProperty] {
        return [_email, _password]
    }
}

extension SignInDto {
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    static func validateEmail(_ email: String) -> Result<String, ValidationError> {
        SignInDto()._email.isValid(value: email)
    }
    
    static func validatePassword(_ password: String) -> Result<String, ValidationError> {
        SignInDto()._password.isValid(value: password)
    }
}
