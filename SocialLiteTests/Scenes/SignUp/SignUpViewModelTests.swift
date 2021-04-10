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
import Resolver

@testable import SocialLite
class SignUpViewModelTests: QuickSpec {
    typealias ViewModel = SignUpViewModel
    typealias User = SocialLite.User
    
    private var viewModel: ViewModel!
    private var router: WeakRouter<AuthenticateRoute>!
    private var useCase: SignUpUseCaseMock? { viewModel.useCase as? SignUpUseCaseMock }
    private var delegate: PublishSubject<User>!
    private var input: ViewModel.Input!
    private var output: ViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Triggers
    private let emailInput = PublishSubject<String>()
    private let passwordInput = PublishSubject<String>()
    private let confirmPasswordInput = PublishSubject<String>()
    private let submitTrigger = PublishSubject<Void>()
    
    // Outputs
    private var emailValidationOutput: TestableObserver<String>!
    private var passwordValidationOutput: TestableObserver<String>!
    private var confirmPasswordValidationOutput: TestableObserver<String>!
    private var isLoadingOutput: TestableObserver<Bool>!
    
    override func spec() {
        
        beforeSuite {
            Resolver.main.register { SignUpUseCaseMock() as SignUpUseCaseType }
        }
        
        describe("As a SignUpViewModel") {
            
            beforeEach {
                self.router = AuthenticateCoordinator().weakRouter
                self.delegate = PublishSubject()
                self.viewModel = ViewModel(router: self.router, delegate: self.delegate)
                
                
                self.input = ViewModel.Input(
                    email: self.emailInput.asDriverOnErrorJustComplete(),
                    password: self.passwordInput.asDriverOnErrorJustComplete(),
                    confirmPassword: self.confirmPasswordInput.asDriverOnErrorJustComplete(),
                    submitTrigger: self.submitTrigger.asDriver(onErrorJustReturn: ())
                )
                
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
                
                self.output = self.viewModel.transform(self.input, disposeBag: self.disposeBag)
                
                self.emailValidationOutput = self.scheduler.createObserver(String.self)
                self.passwordValidationOutput = self.scheduler.createObserver(String.self)
                self.confirmPasswordValidationOutput = self.scheduler.createObserver(String.self)
                self.isLoadingOutput = self.scheduler.createObserver(Bool.self)
                
                self.output.$emailValidationMessage
                    .subscribe(self.emailValidationOutput)
                    .disposed(by: self.disposeBag)
                self.output.$passwordValidationMessage
                    .subscribe(self.passwordValidationOutput)
                    .disposed(by: self.disposeBag)
                self.output.$confirmPasswordValidationMessage
                    .subscribe(self.confirmPasswordValidationOutput)
                    .disposed(by: self.disposeBag)
                self.output.$isLoading
                    .subscribe(self.isLoadingOutput)
                    .disposed(by: self.disposeBag)
            }
            
            it("press confirm -> input fields -> press confirm") {
                
                /// Given
                let inputEmail = self.scheduler.createHotObservable([
                    .next(200, ""),
                    .next(220, "aaa"),
                    .next(240, "john.doe@gmail.com"),
                ])
                
                let inputPassword = self.scheduler.createHotObservable([
                    .next(200, ""),
                    .next(220, "bbb"),
                    .next(260, "ccc"),
                    .next(280, "ccc88888"),
                ])
                
                let inputConfirmPassword = self.scheduler.createHotObservable([
                    .next(200, ""),
                    .next(220, "ccc"),
                    .next(260, "ccc77777"),
                    .next(300, "ccc88888"),
                ])
                
                let submitTapped = self.scheduler.createHotObservable([
                    .next(210, ()),
                    .next(230, ()),
                    .next(250, ()),
                    .next(270, ()),
                    .next(290, ()),
                    .next(310, ()),
                ])
                
                /// When
                inputEmail
                    .bind(to: self.emailInput)
                    .disposed(by: self.disposeBag)
                
                inputPassword
                    .bind(to: self.passwordInput)
                    .disposed(by: self.disposeBag)
                
                inputConfirmPassword
                    .bind(to: self.confirmPasswordInput)
                    .disposed(by: self.disposeBag)
                
                submitTapped
                    .bind(to: self.submitTrigger)
                    .disposed(by: self.disposeBag)

                self.scheduler.start()
                
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
                    .next(250, "Password is too short"),
                    .next(270, "Confirm password should be match password"),
                    .next(290, "Confirm password should be match password"),
                    .next(310, ""),
                ])

                
                expect(self.emailValidationOutput.events).to(equal(expectedEmailErrors))
                expect(self.passwordValidationOutput.events).to(equal(expectedPasswordErrors))
                expect(self.confirmPasswordValidationOutput.events).to(equal(expectedConfirmPasswordErrors))
                expect(self.useCase?.validateEmailCalled).to(beTrue())
                expect(self.useCase?.validatePasswordCalled).to(beTrue())
                expect(self.useCase?.validateConfirmPasswordCalled).to(beTrue())
            }
            
            it("input fields -> press confirm") {
                
                /// Given
                let inputEmail = self.scheduler.createColdObservable([
                    .next(200, "john.doe@gmail.com"),
                ])
                
                let inputPassword = self.scheduler.createColdObservable([
                    .next(300, "ccc88888"),
                ])
                
                let inputConfirmPassword = self.scheduler.createColdObservable([
                    .next(300, "ccc88888"),
                ])
                
                let submitTapped = self.scheduler.createColdObservable([
                    .next(210, ()),
                    .next(310, ()),
                ])
                
                /// When
                inputEmail
                    .bind(to: self.emailInput)
                    .disposed(by: self.disposeBag)
                
                inputPassword
                    .bind(to: self.passwordInput)
                    .disposed(by: self.disposeBag)
                
                inputConfirmPassword
                    .bind(to: self.confirmPasswordInput)
                    .disposed(by: self.disposeBag)
                
                submitTapped
                    .bind(to: self.submitTrigger)
                    .disposed(by: self.disposeBag)
                let delegateTriggered = self.scheduler.record(self.delegate)

                self.scheduler.start()
                
                /// Then
                let expectedEmailErrors: [Recorded<Event<String>>] = [
                    .next(0, ""),
                    .next(210, ""),
                    .next(310, ""),
                ]
                let expectedPasswordErrors: [Recorded<Event<String>>] = [
                    .next(0, ""),
                    .next(310, ""),
                ]
                
                let expectedConfirmPasswordErrors: [Recorded<Event<String>>] = [
                    .next(0, ""),
                    .next(310, ""),
                ]
                let loadingExpected: [Recorded<Event<Bool>>] = [
                    .next(0, false),
                    .next(310, true),
                    .next(310, false)
                ]
                let delegateExpected: [Recorded<Event<User>>] = [
                    .next(310, User(uid: "john.doe@gmail.com", providerID: "test"))
                ]
                
                expect(self.emailValidationOutput.events).to(equal(expectedEmailErrors))
                expect(self.passwordValidationOutput.events).to(equal(expectedPasswordErrors))
                expect(self.confirmPasswordValidationOutput.events).to(equal(expectedConfirmPasswordErrors))
                expect(self.useCase?.validateEmailCalled).to(beTrue())
                expect(self.useCase?.validatePasswordCalled).to(beTrue())
                expect(self.useCase?.validateConfirmPasswordCalled).to(beTrue())
                expect(self.useCase?.signUpCalled).to(beTrue())
                expect(self.isLoadingOutput.events) == loadingExpected
                expect(delegateTriggered.events) == delegateExpected
            }
        }
    }
}
