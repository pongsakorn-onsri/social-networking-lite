//
//  UserManager.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation

final class UserManager: NSObject {
    static var shared = UserManager()
    
    private override init() {
        
    }
    
    public var user: User?
}

class User {
    
}
