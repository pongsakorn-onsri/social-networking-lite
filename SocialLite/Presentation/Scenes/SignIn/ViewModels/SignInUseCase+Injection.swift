//
//  SignInUseCase+Injection.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Resolver
import FirebaseAuth

extension Resolver {
    
    public static func registerSignInUseCase() {
        register { () -> AuthenGatewayType? in
            let auth = Auth.auth()
            return AuthenGateway(auth: auth) as AuthenGatewayType
        }
        
        register { (resolver) -> SignInUseCaseType? in
            SignInUseCase(authenGateway: resolver.resolve())
        }
    }
}
