//
//  SigningInTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import RxSwift
import RxTest
import FirebaseAuth
import GoogleSignIn
import ValidatedPropertyKit

@testable import SocialLite
class SigningInTests: QuickSpec, SigningIn {
    
    typealias User = SocialLite.User
    var authenGateway: AuthenGatewayType {
        authenMock
    }
    
    private var authenMock: AuthenGatewayMock!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    override func spec() {
        
        describe("As a SigningIn usecase") {
            beforeEach {
                self.authenMock = AuthenGatewayMock()
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
            }
            
            it("cannot signin with error") {
                // Given
                let userObserver = self.scheduler.createObserver(User.self)
                let dto = SignInDto(email: "email", password: "")
                
                // When
                
                self.signIn(dto: dto)
                    .subscribe(userObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                let onError = userObserver.events.last?.value.error as? ValidationError
                expect(self.authenMock.signInCalled).to(beFalse())
                expect(onError).toNot(beNil())
                expect(onError?.description).to(contain("Not valid email format."))
            }
            
            it("can signin") {
                // Given
                let userObserver = self.scheduler.createObserver(User.self)
                let dto = SignInDto(email: "email@email.com", password: "12345678")
                
                // When
                
                self.signIn(dto: dto)
                    .subscribe(userObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                let user = User(uid: "", providerID: "")
                
                expect(self.authenMock.signInCalled).to(beTrue())
                expect(userObserver.events).to(equal([.next(0, user),
                                                      .completed(0)]))
            }
            
            it("can signin credential") {
                // Given
                let userObserver = self.scheduler.createObserver(User.self)
                let credential = GoogleAuthProvider.credential(withIDToken: "", accessToken: "")
                
                // When
                
                self.signIn(with: credential)
                    .subscribe(userObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                let user = User(uid: "", providerID: "")
                
                expect(self.authenMock.signInCredentialCalled).to(beTrue())
                expect(userObserver.events).to(equal([.next(0, user),
                                                      .completed(0)]))
            }
            
            it("can validate email") {
                var email = ""
                expect(self.validateEmail(email).firstMessage).to(match("Please input email account."))
                expect(self.validateEmail(email).isValid).to(beFalse())
                
                email = "email"
                expect(self.validateEmail(email).firstMessage).to(match("Not valid email format."))
                expect(self.validateEmail(email).isValid).to(beFalse())
                
                email = "email@gmail.com"
                expect(self.validateEmail(email).firstMessage) == ""
                expect(self.validateEmail(email).isValid).to(beTrue())
            }
            
            it("can validate password") {
                var password = ""
                expect(self.validatePassword(password).firstMessage).to(match("Please input your password."))
                expect(self.validatePassword(password).isValid).to(beFalse())
                
                password = "1234"
                expect(self.validatePassword(password).firstMessage).to(match("Password is too short"))
                expect(self.validatePassword(password).isValid).to(beFalse())

                password = "88888888"
                expect(self.validatePassword(password).firstMessage) == ""
                expect(self.validatePassword(password).isValid).to(beTrue())
            }
        }
    }

}
