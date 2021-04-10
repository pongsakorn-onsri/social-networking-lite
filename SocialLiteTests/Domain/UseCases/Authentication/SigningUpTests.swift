//
//  SigningUpTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import RxSwift
import RxTest
import Dto
import ValidatedPropertyKit

@testable import SocialLite
class SigningUpTests: QuickSpec, SigningUp {
    
    var authenGateway: AuthenGatewayType {
        authenMock
    }
    
    private var authenMock: MockAuthen!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!

    override func spec() {
        describe("As a SigningUp") {
            beforeEach {
                self.authenMock = MockAuthen()
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
            }
            
            it("can signup") {
                // Given
                let dto = SignUpDto(email: "email@email.com", password: "12345678", confirmPassword: "12345678")
                let userObserver = self.scheduler.createObserver(User.self)
                
                // When
                self.signUp(dto: dto)
                    .subscribe(userObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                let expectedUserEvents: [Recorded<Event<User>>] = [
                    .next(0, User(uid: "email@email.com", providerID: "")),
                    .completed(0)
                ]
                
                expect(userObserver.events).to(equal(expectedUserEvents))
                expect(self.authenMock.signUpCalled).to(beTrue())
            }
            
            it("cannot signup with error") {
                // Given
                let dto = SignUpDto()
                let userObserver = self.scheduler.createObserver(User.self)
                
                // When
                self.signUp(dto: dto)
                    .subscribe(userObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                
                expect(userObserver.events.last?.value.error).toNot(beNil())
                expect(self.authenMock.signUpCalled).to(beFalse())
            }
            
            it("can validate email") {
                var email = ""
                expect(self.validateEmail(email).firstMessage).to(match("Please input your email address."))
                expect(self.validateEmail(email).isValid).to(beFalse())
                
                email = "email"
                expect(self.validateEmail(email).firstMessage).to(match("Your email address incorrect format."))
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
            
            it("can validate confirm password") {
                var password = ""
                var confirmPassword = ""
                
                expect(self.validateConfirmPassword(confirmPassword, password).firstMessage).to(match("Please input your confirm password."))
                expect(self.validateConfirmPassword(confirmPassword, password).isValid).to(beFalse())
                
                password = "1234"
                confirmPassword = "5555"
                expect(self.validateConfirmPassword(confirmPassword, password).firstMessage).to(match("Password is too short"))
                expect(self.validateConfirmPassword(confirmPassword, password).isValid).to(beFalse())
                
                password = "88888888"
                confirmPassword = "999999999"
                expect(self.validateConfirmPassword(confirmPassword, password).firstMessage).to(match("Confirm password should be match password"))
                expect(self.validateConfirmPassword(confirmPassword, password).isValid).to(beFalse())

                password = "88888888"
                confirmPassword = "88888888"
                expect(self.validateConfirmPassword(confirmPassword, password).firstMessage) == ""
                expect(self.validateConfirmPassword(confirmPassword, password).isValid).to(beTrue())
            }
            
        }
    }

}
