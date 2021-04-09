//
//  FeedUseCase+Injection.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import Resolver

extension Resolver {
    
    public static func registerFeedUseCase() {
        register {
            FeedUseCase() as FeedUseCaseType
        }
        
        register {
            PostGateway() as PostGatewayType
        }
    }
}
