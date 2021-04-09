//
//  CreatePostUseCase+Injected.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import Resolver
import FirebaseAuth

extension Resolver {
    
    public static func registerCreatePostUseCase() {
        register { () -> PostGatewayType? in
            PostGateway() as PostGatewayType
        }
        
        register {
            CreatePostUseCase() as CreatePostUseCaseType
        }
    }
}
