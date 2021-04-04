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

            beforeEach {
                viewModel = ViewModel(with: self.router)
                scheduler = TestScheduler(initialClock: 0)
                self.disposeBag = DisposeBag()
            }
            
            it("press confirm -> input fields -> press confirm") {
                
                /// Given
                let inputEmail = scheduler.createHotObservable([
                    .next(220, "aaa"),
                    .next(240, "john.doe@gmail.com"),
                ])
                .asObservable()
                
                let inputPassword = scheduler.createHotObservable([
                    .next(220, "bbb"),
                    .next(260, "ccc"),
                    .next(280, "ccc88888"),
                ])
                .asObservable()
                
                let inputConfirmPassword = scheduler.createHotObservable([
                    .next(220, "ccc"),
                    .next(260, "ccc77777"),
                    .next(300, "ccc88888"),
                ])
                .asObservable()
                
                let submitTapped = scheduler.createHotObservable([
                    .next(210, ()),
                    .next(230, ()),
                    .next(250, ()),
                    .next(270, ()),
                    .next(290, ()),
                    .next(310, ()),
                ])
                .asObservable()
            
                let input = ViewModel.Input(email: inputEmail,
                                            password: inputPassword,
                                            confirmPassword: inputConfirmPassword,
                                            submitTapped: submitTapped)
                
                let output = viewModel.transform(input: input)
                
                /// When
                let outputEmailError = scheduler.createObserver(String?.self)
                let outputPasswordError = scheduler.createObserver(String?.self)
                let outputConfirmPasswordError = scheduler.createObserver(String?.self)
                
                output.emailError
                    .map { $0?.localizedDescription }
                    .drive(outputEmailError)
                    .disposed(by: self.disposeBag)
                output.passwordError
                    .map { $0?.localizedDescription }
                    .drive(outputPasswordError)
                    .disposed(by: self.disposeBag)
                output.confirmPasswordError
                    .map { $0?.localizedDescription }
                    .drive(outputConfirmPasswordError)
                    .disposed(by: self.disposeBag)
                
                scheduler.start()
                
                /// Then
                
                let expectedEmailErrors: [Recorded<Event<String?>>] = Recorded.events([
                    .next(210, "Please input your email address."),
                    .next(230, "Your email address incorrect format."),
                    .next(250, nil),
                    .next(270, nil),
                    .next(290, nil),
                    .next(310, nil),
                ])
                
                let expectedPasswordErrors: [Recorded<Event<String?>>] = Recorded.events([
                    .next(210, "Please input your password."),
                    .next(230, "Password is too short"),
                    .next(250, "Password is too short"),
                    .next(270, "Password is too short"),
                    .next(290, nil),
                    .next(310, nil),
                ])
                
                let expectedConfirmPasswordErrors: [Recorded<Event<String?>>] = Recorded.events([
                    .next(210, "Please input your confirm password."),
                    .next(230, "Password is too short"),
                    .next(250, "Password is too short"),
                    .next(270, "Confirm password should be match password"),
                    .next(290, "Confirm password should be match password"),
                    .next(310, nil),
                ])
                
                expect(outputEmailError.events).to(equal(expectedEmailErrors))
                expect(outputPasswordError.events).to(equal(expectedPasswordErrors))
                expect(outputConfirmPasswordError.events).to(equal(expectedConfirmPasswordErrors))
            }
            
        }
    }
}
