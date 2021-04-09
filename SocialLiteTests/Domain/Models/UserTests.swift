//
//  UserTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import XCTest
import Quick
import Nimble
import FirebaseAuth

@testable import SocialLite
class UserTests: QuickSpec {

    override func spec() {
        describe("As a User model") {
            var user: SocialLite.User!
            
            context("can initialize") {
                
                it("with firebase user") {
                    if let firebaseUser = Auth.auth().currentUser {
                        user = User(firebaseUser: firebaseUser)
                        expect(user).toNot(beNil())
                    }
                }
                
                it("with local") {
                    user = SocialLite.User(uid: "", providerID: "email")
                    expect(user).toNot(beNil())
                }
                
            }
            
            context("can compare 2 user") {
                
                it("to equal") {
                    let user1 = SocialLite.User(uid: "123456", providerID: "")
                    let user2 = SocialLite.User(uid: "123456", providerID: "")
                    
                    expect(user1).to(equal(user2))
                }
                
                it("to not equal") {
                    let user1 = SocialLite.User(uid: "123456", providerID: "")
                    let user2 = SocialLite.User(uid: "1234567890", providerID: "")
                    
                    expect(user1).toNot(equal(user2))
                }
                
            }
            
            it("have post display name") {
                user = SocialLite.User(uid: "", providerID: "")
                user.email = "pongsakorn@gmail.com"
                
                expect(user.postDisplayName).to(match("pongsakorn"))
                
                user.displayName = "musashi"
                
                expect(user.postDisplayName).to(match("musashi"))
                
                user.email = nil
                user.displayName = nil
                expect(user.postDisplayName).to(match("Anonymous"))
            }
        }
    }

}
