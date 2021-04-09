//
//  SignUpUseCase+Injection.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import Resolver
import FirebaseAuth

extension Resolver {
    
    public static func registerSignUpUseCase() {
        register { () -> AuthenGatewayType? in
            let auth = Auth.auth()
            return AuthenGateway(auth: auth) as AuthenGatewayType
        }
        
        register {
            SignUpUseCase() as SignUpUseCaseType
        }
    }
}
