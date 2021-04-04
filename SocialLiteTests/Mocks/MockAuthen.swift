//
//  MockAuthen.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 4/4/2564 BE.
//

import Foundation
import XCTest
import Quick
import Nimble
import RxSwift
import RxTest
import XCoordinator
import GoogleSignIn
import Firebase

@testable import SocialLite
class MockAuthen: NSObject, AuthenProtocol {
    var currentUser: User?
    
    func signUp(with email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        completion?(nil, nil)
    }
    
    func signIn(with credential: AuthCredential, completion: ((AuthDataResult?, Error?) -> Void)?) {
        completion?(nil, nil)
    }
    
    func signIn(with email: String, password: String, completion: ((AuthDataResult?, Error?) -> Void)?) {
        completion?(nil, nil)
    }
    
    func signOut() {
        currentUser = nil
    }
}
