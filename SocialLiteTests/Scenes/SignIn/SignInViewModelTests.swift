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
import RxBlocking
import XCoordinator
import GoogleSignIn
import FirebaseAuth

@testable import SocialLite
class SignInViewModelTests: QuickSpec {
    
    typealias ViewModel = SignInViewModel
    
    var disposeBag: DisposeBag!
    var router: WeakRouter<AuthenticateRoute>!

    override func spec() {
        beforeSuite {
            let coordinator = AuthenticateCoordinator()
            self.router = coordinator.weakRouter
        }
        
        describe("As a SignInViewModel") {
            
            var viewModel: ViewModel!
            var scheduler: TestScheduler!
            var delegate: PublishSubject<SocialLite.User>!

            beforeEach {
                delegate = PublishSubject()
                viewModel = ViewModel(router: self.router, delegate: delegate)
                scheduler = TestScheduler(initialClock: 0)
                self.disposeBag = DisposeBag()
            }
            
            context("input email and password") {
                
                it("press sign in") {

                    /// Given
                    let signInTapped = scheduler.createHotObservable([
                        .next(230, ()),
                    ])
                    
                    let input = ViewModel.Input(email: .just(""),
                                                password: .just(""),
                                                signInTapped: signInTapped.asDriver(onErrorJustReturn: ()),
                                                signUpTapped: .never(),
                                                signInGoogle: .never())
                    let output = viewModel.transform(input, disposeBag: self.disposeBag)
                    
                    /// When
                    let outputEmail = scheduler.record(output.$emailValidationMessage)
                    let outputPassword = scheduler.record(output.$passwordValidationMessage)

                    scheduler.start()
                    
                    /// Then
                    expect(outputEmail.events).to(equal([ .next(0, ""),
                                                          .next(230, "Please input email account.") ]))
                    expect(outputPassword.events).to(equal([ .next(0, ""),
                                                             .next(230, "Please input your password.") ]))
                }
                
                it("input email & password -> press sign in") {

                    /// Given
                    let inputEmail = scheduler.createHotObservable([
                        .next(210, "aaaa"),
                        .next(240, "pongsakorn@gmail.com"),
                    ])
                    
                    let inputPassword = scheduler.createHotObservable([
                        .next(220, "bbbb"),
                        .next(250, "Welcome1"),
                    ])
                    
                    let signInTapped = scheduler.createHotObservable([
                        .next(230, ()),
                        .next(260, ()),
                    ])

                    let input = ViewModel.Input(email: inputEmail.asDriverOnErrorJustComplete(),
                                                password: inputPassword.asDriverOnErrorJustComplete(),
                                                signInTapped: signInTapped.asDriver(onErrorJustReturn: ()),
                                                signUpTapped: .never(),
                                                signInGoogle: .never())
                    let output = viewModel.transform(input, disposeBag: self.disposeBag)
                    
                    /// When
                    let outputEmail = scheduler.record(output.$emailValidationMessage)
                    let outputPassword = scheduler.record(output.$passwordValidationMessage)
                    
                    scheduler.start()
                    
                    /// Then
                    expect(outputEmail.events).to(equal([ .next(0, ""),
                                                          .next(230, "Not valid email format."),
                                                          .next(240, ""),
                                                          .next(260, "") ]))
                    expect(outputPassword.events).to(equal([ .next(0, ""),
                                                             .next(230, "Password is too short"),
                                                             .next(250, ""),
                                                             .next(260, "") ]))
                }
            }
            
            
            context("can sign in") {
                
                context("with email and password") {
                    it("by correct email and password") {
                        var onError: Error?
                        var user: SocialLite.User?
                        

                        waitUntil(timeout: .seconds(10)) { (done) in
                            let dto = SignInDto(email: "pongsakorn@gmail.com", password: "Welcome1")
                            
                            viewModel.useCase.signIn(dto: dto)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).to(beNil())
                        expect(user).notTo(beNil())
                    }
                }
            }
            
            context("can not sign in") {
                context("with email and password") {
                    it("by empty value") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let dto = SignInDto(email: "", password: "")
                            
                            viewModel.useCase.signIn(dto: dto)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(user).to(beNil())
                    }
                    
                    it("by wrong password") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let dto = SignInDto(email: "pongsakorn.onsri@gmail.com", password: "123456789")
                            
                            viewModel.useCase.signIn(dto: dto)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The password is invalid or the user does not have a password."))
                        expect(user).to(beNil())
                    }
                    
                    it("by email does not registered") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let dto = SignInDto(email: "aaa.bbb@gmail.com", password: "aaaaaaaa")
                            
                            viewModel.useCase.signIn(dto: dto)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("There is no user record corresponding to this identifier. The user may have been deleted."))
                        expect(user).to(beNil())
                    }
                    
                    it("by only short password") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let dto = SignInDto(email: "", password: "aaaa")
                            
                            viewModel.useCase.signIn(dto: dto)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(user).to(beNil())
                    }
                }
                
                context("with google provider") {
                    it("by empty token") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let credential = GoogleAuthProvider.credential(withIDToken: "", accessToken: "")
                            
                            viewModel.useCase.signIn(with: credential)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                        expect(user).to(beNil())
                    }
                }
                
                context("with github provider") {
                    it("by empty token") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let credential = GitHubAuthProvider.credential(withToken: "")
                            viewModel.useCase.signIn(with: credential)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                        expect(user).to(beNil())
                    }
                }
                
                context("with facebook provider") {
                    it("by empty token") {
                        var onError: Error?
                        var user: SocialLite.User?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            let credential = FacebookAuthProvider.credential(withAccessToken: "")
                            viewModel.useCase.signIn(with: credential)
                                .subscribe(onNext: { value in
                                    user = value
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                        expect(user).to(beNil())
                    }
                }
            }
        }
    }

}
