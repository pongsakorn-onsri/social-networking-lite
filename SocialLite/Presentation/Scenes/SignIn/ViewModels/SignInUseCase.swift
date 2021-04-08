//
//  SignInUseCase.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseAuth
import Dto
import ValidatedPropertyKit

protocol SignInUseCaseType {
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    
    func signIn(dto: SignInDto) -> Observable<User>
    func signIn(with credential: AuthCredential) -> Observable<User>
}

struct SignInUseCase: SignInUseCaseType, SigningIn {
    let authenGateway: AuthenGatewayType
}
