//
//  MockAuthen.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 4/4/2564 BE.
//

import Foundation
import FirebaseAuth

@testable import SocialLite
class MockAuthen: NSObject, AuthenProtocol {
    var currentUser: SocialLite.User?
    
    func signUp(with email: String, password: String, completion: ((SocialLite.User?, Error?) -> Void)?) {
        let user = User(uid: "", providerID: "")
        completion?(user, nil)
    }
    
    func signIn(with credential: AuthCredential, completion: ((SocialLite.User?, Error?) -> Void)?) {
        let user = User(uid: "", providerID: "")
        completion?(user, nil)
    }
    
    func signIn(with email: String, password: String, completion: ((SocialLite.User?, Error?) -> Void)?) {
        let user = User(uid: "", providerID: "")
        completion?(user, nil)
    }
    
    func signOut() {
        currentUser = nil
    }
}
