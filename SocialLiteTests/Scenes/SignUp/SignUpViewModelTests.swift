//
//  SignUpViewModelTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 4/4/2564 BE.
//

import XCTest
import Quick
import Nimble
import RxSwift
import RxTest
import RxBlocking
import XCoordinator
import GoogleSignIn
import FirebaseAuth

@testable import SocialLite

class SignUpViewModelTests: QuickSpec {

    typealias ViewModel = SignUpViewModel
    
    var disposeBag: DisposeBag!
    var router: WeakRouter<AuthenticateRoute>!
    
    override func spec() {
        
        beforeSuite {
            let coordinator = AuthenticateCoordinator()
            self.router = coordinator.weakRouter
        }
        
        describe("As a SignUpViewModel") {
            
            var viewModel: ViewModel!
            var scheduler: TestScheduler!
            var delegate: PublishSubject<SocialLite.User>!

            beforeEach {
                delegate = PublishSubject()
                viewModel = ViewModel(router: self.router, delegate: delegate)
                scheduler = TestScheduler(initialClock: 0)
                self.disposeBag = DisposeBag()
            }
            
            it("press confirm -> input fields -> press confirm") {
                
                /// Given
                let inputEmail = scheduler.createHotObservable([
                    .next(200, ""),
                    .next(220, "aaa"),
                    .next(240, "john.doe@gmail.com"),
                ])
                .asDriverOnErrorJustComplete()
                
                let inputPassword = scheduler.createHotObservable([
                    .next(200, ""),
                    .next(220, "bbb"),
                    .next(260, "ccc"),
                    .next(280, "ccc88888"),
                ])
                .asDriverOnErrorJustComplete()
                
                let inputConfirmPassword = scheduler.createHotObservable([
                    .next(200, ""),
                    .next(220, "ccc"),
                    .next(260, "ccc77777"),
                    .next(300, "ccc88888"),
                ])
                .asDriverOnErrorJustComplete()
                
                let submitTapped = scheduler.createHotObservable([
                    .next(210, ()),
                    .next(230, ()),
                    .next(250, ()),
                    .next(270, ()),
                    .next(290, ()),
                    .next(310, ()),
                ])
                .asDriverOnErrorJustComplete()

                let input = ViewModel.Input(email: inputEmail,
                                            password: inputPassword,
                                            confirmPassword: inputConfirmPassword,
                                            submitTrigger: submitTapped)
                
                let output = viewModel.transform(input, disposeBag: self.disposeBag)
                
                /// When
                let outputEmail = scheduler.record(output.$emailValidationMessage)
                let outputPassword = scheduler.record(output.$passwordValidationMessage)
                let outputConfirmPassword = scheduler.record(output.$confirmPasswordValidationMessage)
                
                scheduler.start()
                
                /// Then
                
                let expectedEmailErrors: [Recorded<Event<String>>] = Recorded.events([
                    .next(0, ""),
                    .next(210, "Please input your email address."),
                    .next(230, "Your email address incorrect format."),
                    .next(250, ""),
                    .next(270, ""),
                    .next(290, ""),
                    .next(310, ""),
                ])
                
                let expectedPasswordErrors: [Recorded<Event<String>>] = Recorded.events([
                    .next(0, ""),
                    .next(210, "Please input your password."),
                    .next(230, "Password is too short"),
                    .next(250, "Password is too short"),
                    .next(270, "Password is too short"),
                    .next(290, ""),
                    .next(310, ""),
                ])
                
                let expectedConfirmPasswordErrors: [Recorded<Event<String>>] = Recorded.events([
                    .next(0, ""),
                    .next(210, "Please input your confirm password."),
                    .next(230, "Password is too short"),
                    .next(250, "Confirm password should be match password"),
                    .next(270, "Confirm password should be match password"),
                    .next(290, "Confirm password should be match password"),
                    .next(310, "Confirm password should be match password"),
                ])

                
                expect(outputEmail.events).to(equal(expectedEmailErrors))
                expect(outputPassword.events).to(equal(expectedPasswordErrors))
                expect(outputConfirmPassword.events).to(equal(expectedConfirmPasswordErrors))
            }
            
        }
    }
}
