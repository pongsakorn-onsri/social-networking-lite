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

            beforeEach {
                viewModel = ViewModel(with: self.router)
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
                                                 signInTapped: signInTapped.asObservable(),
                                                 signUpTapped: .just(()))
                    let output = viewModel.transform(input: input)
                    
                    /// When
                    let outputEmailObserver = scheduler.createObserver(String?.self)
                    let disposable = output.emailError
                        .map { $0?.localizedDescription }
                        .drive(outputEmailObserver)
                    
                    let outputPasswordObserver = scheduler.createObserver(String?.self)
                    let disposable2 = output.passwordError
                        .map { $0?.localizedDescription }
                        .drive(outputPasswordObserver)
                    
                    scheduler.scheduleAt(1000) {
                        disposable.dispose()
                        disposable2.dispose()
                    }
                    
                    scheduler.start()
                    
                    /// Then
                    expect(outputEmailObserver.events).to(equal([ .next(230, "Please input email account.") ]))
                    expect(outputPasswordObserver.events).to(equal([ .next(230, "Please input your password.") ]))
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

                    let input = ViewModel.Input(email: inputEmail.asObservable(),
                                                password: inputPassword.asObservable(),
                                                 signInTapped: signInTapped.asObservable(),
                                                 signUpTapped: .just(()))
                    let output = viewModel.transform(input: input)
                    
                    /// When
                    let outputEmailObserver = scheduler.createObserver(String?.self)
                    let disposable = output.emailError
                        .map { $0?.localizedDescription }
                        .drive(outputEmailObserver)
                    
                    let outputPasswordObserver = scheduler.createObserver(String?.self)
                    let disposable2 = output.passwordError
                        .map { $0?.localizedDescription }
                        .drive(outputPasswordObserver)
                    
                    scheduler.scheduleAt(1000) {
                        disposable.dispose()
                        disposable2.dispose()
                    }
                    
                    scheduler.start()
                    
                    /// Then
                    expect(outputEmailObserver.events).to(equal([ .next(230, nil),
                                                                  .next(260, nil) ]))
                    expect(outputPasswordObserver.events).to(equal([ .next(230, nil),
                                                                     .next(260, nil) ]))
                }
            }
            
            
            context("can sign in") {
                
                context("with email and password") {
                    it("by correct email and password") {
                        var onError: Error?
                        
                        viewModel.signIn(with: "pongsakorn@gmail.com", password: "Welcome1")

                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                        }
                        
                        expect(onError).to(beNil())
                        expect(UserManager.shared.currentUser).notTo(beNil())
                    }
                }
            }
            
            context("can not sign in") {
                context("with email and password") {
                    it("by empty value") {
                        var onError: Error?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: "", password: "")
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The password is invalid or the user does not have a password."))
                    }
                    
                    it("by wrong password") {
                        var onError: Error?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: "pongsakorn.onsri@gmail.com", password: "123456789")
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The password is invalid or the user does not have a password."))
                    }
                    
                    it("by email does not registered") {
                        var onError: Error?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: "aaa.bbb@gmail.com", password: "aaa")
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("There is no user record corresponding to this identifier. The user may have been deleted."))
                    }
                    
                    it("by only short password") {
                        var onError: Error?
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: "", password: "aaa")
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The email address is badly formatted."))
                    }
                }
                
                context("with google provider") {
                    it("by empty token") {
                        var onError: Error?
                        let credential = GoogleAuthProvider.credential(withIDToken: "", accessToken: "")
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: credential)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                    }
                }
                
                context("with github provider") {
                    it("by empty token") {
                        var onError: Error?
                        let credential = GitHubAuthProvider.credential(withToken: "")
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: credential)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                    }
                }
                
                context("with facebook provider") {
                    it("by empty token") {
                        var onError: Error?
                        let credential = FacebookAuthProvider.credential(withAccessToken: "")
                        
                        waitUntil(timeout: .seconds(10)) { (done) in
                            viewModel.signInErrorSubject
                                .subscribe(onNext: { error in
                                    onError = error
                                    done()
                                }, onError: { error in
                                    onError = error
                                    done()
                                })
                                .disposed(by: self.disposeBag)
                            
                            viewModel.signIn(with: credential)
                        }
                        
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                    }
                }
            }
        }
    }

}
