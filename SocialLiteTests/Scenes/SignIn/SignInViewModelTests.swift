//
//  SignInViewModelTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 4/4/2564 BE.
//

import XCTest
import Quick
import Nimble
import RxSwift
import RxTest
import XCoordinator
import GoogleSignIn
import FirebaseAuth
import Resolver

@testable import SocialLite
class SignInViewModelTests: QuickSpec {
    typealias User = SocialLite.User
    private var viewModel: SignInViewModel!
    private var router: WeakRouter<AuthenticateRoute>!
    private var useCase: SignInUseCaseMock? { viewModel.useCase as? SignInUseCaseMock }
    private var delegate: PublishSubject<User>!
    private var input: SignInViewModel.Input!
    private var output: SignInViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Outputs
    private var emailValidationOutput: TestableObserver<String>!
    private var passwordValidationOutput: TestableObserver<String>!
    private var isLoadingOutput: TestableObserver<Bool>!
    
    // Triggers
    private let emailTrigger = PublishSubject<String>()
    private let passwordTrigger = PublishSubject<String>()
    private let signInTrigger = PublishSubject<Void>()
    private let signUpTrigger = PublishSubject<Void>()
    private let signInGoogleTrigger = PublishSubject<AuthCredential>()

    override func spec() {
        beforeSuite {
            Resolver.main.register { SignInUseCaseMock() as SignInUseCaseType }
        }
        
        describe("As a SignInViewModel") {

            beforeEach {
                self.router = AuthenticateCoordinator().weakRouter
                self.delegate = PublishSubject()
                self.viewModel = SignInViewModel(
                    router: self.router,
                    delegate: self.delegate
                )
                
                self.input = SignInViewModel.Input(
                    email: self.emailTrigger.asDriverOnErrorJustComplete(),
                    password: self.passwordTrigger.asDriverOnErrorJustComplete(),
                    signInTapped: self.signInTrigger.asDriverOnErrorJustComplete(),
                    signUpTapped: self.signUpTrigger.asDriverOnErrorJustComplete(),
                    signInGoogle: self.signInGoogleTrigger.asDriverOnErrorJustComplete()
                )
                
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
                
                self.output = self.viewModel.transform(self.input, disposeBag: self.disposeBag)
                self.isLoadingOutput = self.scheduler.createObserver(Bool.self)
                self.emailValidationOutput = self.scheduler.createObserver(String.self)
                self.passwordValidationOutput = self.scheduler.createObserver(String.self)
                
                self.output.$emailValidationMessage
                    .subscribe(self.emailValidationOutput)
                    .disposed(by: self.disposeBag)
                
                self.output.$passwordValidationMessage
                    .subscribe(self.passwordValidationOutput)
                    .disposed(by: self.disposeBag)
                
                self.output.$isLoading
                    .subscribe(self.isLoadingOutput)
                    .disposed(by: self.disposeBag)
            }
            
            context("input email and password") {
                
                it("press sign in") {

                    /// Given
                    let emailInput = self.scheduler.createColdObservable([
                        .next(0, ""),
                    ])
                    
                    let passwordInput = self.scheduler.createColdObservable([
                        .next(0, ""),
                    ])
                    
                    let signInTapped = self.scheduler.createColdObservable([
                        .next(230, ()),
                    ])
                    
                    /// When
                    emailInput
                        .bind(to: self.emailTrigger)
                        .disposed(by: self.disposeBag)
                    
                    passwordInput
                        .bind(to: self.passwordTrigger)
                        .disposed(by: self.disposeBag)
                    
                    signInTapped
                        .bind(to: self.signInTrigger)
                        .disposed(by: self.disposeBag)
                    
                    self.scheduler.start()
                    
                    /// Then
                    let loadingExpected: [Recorded<Event<Bool>>] = [
                        .next(0, false)
                    ]
                    
                    expect(self.emailValidationOutput.events).to(equal([ .next(0, ""),
                                                                         .next(230, "Please input email account.") ]))
                    expect(self.passwordValidationOutput.events).to(equal([ .next(0, ""),
                                                                            .next(230, "Please input your password.") ]))
                    expect(self.isLoadingOutput.events).to(equal(loadingExpected))
                    expect(self.useCase?.validateEmailCalled).to(beTrue())
                    expect(self.useCase?.validatePasswordCalled).to(beTrue())
                }
                
                it("input email & password -> press sign in") {

                    /// Given
                    let inputEmail = self.scheduler.createHotObservable([
                        .next(210, "aaaa"),
                        .next(240, "pongsakorn@gmail.com"),
                    ])
                    
                    let inputPassword = self.scheduler.createHotObservable([
                        .next(220, "bbbb"),
                        .next(250, "Welcome1"),
                    ])
                    
                    let signInTapped = self.scheduler.createHotObservable([
                        .next(230, ()),
                        .next(260, ()),
                    ])
                    
                    /// When
                    inputEmail
                        .bind(to: self.emailTrigger)
                        .disposed(by: self.disposeBag)
                    
                    inputPassword
                        .bind(to: self.passwordTrigger)
                        .disposed(by: self.disposeBag)
                    
                    signInTapped
                        .bind(to: self.signInTrigger)
                        .disposed(by: self.disposeBag)
                    
                    let delegateTriggered = self.scheduler.record(self.delegate)
                    
                    self.scheduler.start()
                    
                    /// Then
                    let loadingExpected: [Recorded<Event<Bool>>] = [
                        .next(0, false),
                        .next(260, true),
                        .next(260, false)
                    ]
                    let delegateExpected: [Recorded<Event<User>>] = [
                        .next(260, User(uid: "pongsakorn@gmail.com", providerID: "test"))
                    ]
                    
                    expect(self.emailValidationOutput.events).to(equal([ .next(0, ""),
                                                                         .next(230, "Not valid email format."),
                                                                         .next(240, ""),
                                                                         .next(260, "") ]))
                    expect(self.passwordValidationOutput.events).to(equal([ .next(0, ""),
                                                                            .next(230, "Password is too short"),
                                                                            .next(250, ""),
                                                                            .next(260, "") ]))
                    expect(delegateTriggered.events).to(equal(delegateExpected))
                    expect(self.isLoadingOutput.events).to(equal(loadingExpected))
                    expect(self.useCase?.signInCalled).to(beTrue())
                    expect(self.useCase?.validateEmailCalled).to(beTrue())
                    expect(self.useCase?.validatePasswordCalled).to(beTrue())
                }
            }

            context("sign in with provider") {
                it("press google sign") {
                    // Given
                    let googleSignInTrigger = self.scheduler.createHotObservable([
                        .next(230, GoogleAuthProvider.credential(withIDToken: "", accessToken: "")),
                    ])
                    
                    // When
                    googleSignInTrigger
                        .subscribe(self.signInGoogleTrigger)
                        .disposed(by: self.disposeBag)
                    
                    self.scheduler.start()
                    
                    // Then
                    expect(self.useCase?.signInCredential).to(beTrue())
                }
            }
        }
    }

}
