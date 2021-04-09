//
//  AppDelegate+Injection.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerSignInUseCase()
        registerSignUpUseCase()
        registerCreatePostUseCase()
    }
}
