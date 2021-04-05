//
//  UserManagerTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 5/4/2564 BE.
//

import Foundation
import Quick
import Nimble
import RxSwift
import FirebaseAuth

@testable import SocialLite
class UserManagerTests: QuickSpec {
    
    var disposeBag: DisposeBag!
    
    override func spec() {
        
        describe("As a UserManager") {
            
            var authen: MockAuthen!
            
            beforeEach {
                authen = MockAuthen()
            }
            
            context("initialize") {
                it("without user") {
                    let userManager = UserManager(auth: authen)
                    expect(userManager.currentUser).to(beNil())
                }
                
                it("with current user") {
                    authen.currentUser = User(uid: "", providerID: "")
                    let userManager = UserManager(auth: authen)
                    expect(userManager.currentUser).toNot(beNil())
                }
            }
            
            context("can sign in") {
                
                var userManager: UserManager!
                
                beforeEach {
                    userManager = UserManager(auth: authen)
                    self.disposeBag = DisposeBag()
                }
                
                it("with email and password") {
                    var user: SocialLite.User?
                    var onError: Error?
                    
                    waitUntil(timeout: .seconds(10)) { (done) in
                        userManager.signIn(with: "", password: "")
                            .subscribe(onSuccess: { value in
                                user = value
                                done()
                            }, onError: { error in
                                onError = error
                                done()
                            })
                            .disposed(by: self.disposeBag)
                    }
                    
                    expect(user).notTo(beNil())
                    expect(onError).to(beNil())
                }
                
                it("with google provider") {
                    let googleProvider = GoogleAuthProvider.credential(withIDToken: "", accessToken: "")
                    var user: SocialLite.User?
                    var onError: Error?
                    
                    waitUntil(timeout: .seconds(10)) { (done) in
                        userManager.signIn(with: googleProvider)
                            .subscribe(onSuccess: { value in
                                user = value
                                done()
                            }, onError: { error in
                                onError = error
                                done()
                            })
                            .disposed(by: self.disposeBag)
                    }
                    
                    expect(user).notTo(beNil())
                    expect(onError).to(beNil())
                }
            }
            
            context("can sign up") {
                var userManager: UserManager!
                
                beforeEach {
                    userManager = UserManager(auth: authen)
                    self.disposeBag = DisposeBag()
                }
                
                it("with email and password") {
                    var user: SocialLite.User?
                    var onError: Error?
                    
                    waitUntil(timeout: .seconds(10)) { (done) in
                        userManager.signUp(with: "", password: "")
                            .subscribe(onSuccess: { value in
                                user = value
                                done()
                            }, onError: { error in
                                onError = error
                                done()
                            })
                            .disposed(by: self.disposeBag)
                    }
                    
                    expect(user).notTo(beNil())
                    expect(onError).to(beNil())
                }
            }
            
            context("can sign out") {
                it("without user") {
                    let userManager = UserManager(auth: authen)
                    expect(userManager.currentUser).to(beNil())
                    
                    userManager.signOut()
                    expect(userManager.currentUser).to(beNil())
                }
                
                it("with current user") {
                    authen.currentUser = User(uid: "", providerID: "")
                    let userManager = UserManager(auth: authen)
                    expect(userManager.currentUser).toNot(beNil())
                    
                    userManager.signOut()
                    expect(userManager.currentUser).to(beNil())
                }
            }
        }
    }
}
