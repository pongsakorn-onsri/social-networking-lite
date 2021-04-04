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
                it("input empty email > press sign in") {

                    /// Given
                    let inputEmail = scheduler.createHotObservable([
                        .next(0, ""),
                    ])
                    
                    let signInTapped = scheduler.createHotObservable([
                        .next(1, ()),
                    ])

                    let input = ViewModel.Input(email: inputEmail.asObservable(),
                                                 password: .just(""),
                                                 signInTapped: signInTapped.asObservable(),
                                                 signUpTapped: .just(()))
                    let output = viewModel.transform(input: input)
                    
                    /// When
                    let outputEmailErrors = scheduler.start {
                        output.emailError
                            .asObservable()
                            .map { error in
                                error?.localizedDescription
                            }
                    }
                    _ = scheduler.start { signInTapped.asObservable() }
                    scheduler.start()
                    
                    /// Then
                    let expectedEmailErrors: [Recorded<Event<String?>>] = Recorded.events(
                        .next(0, nil),
                        .next(2, "Please input email account.")
                    )

                    expect(outputEmailErrors.events).to(equal(expectedEmailErrors))
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
                        viewModel.signIn(with: "", password: "")
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The password is invalid or the user does not have a password."))
                    }
                    
                    it("by wrong password") {
                        var onError: Error?
                        viewModel.signIn(with: "pongsakorn.onsri@gmail.com", password: "123456789")
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The password is invalid or the user does not have a password."))
                    }
                    
                    it("by email does not registered") {
                        var onError: Error?
                        viewModel.signIn(with: "aaa.bbb@gmail.com", password: "aaa")
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("There is no user record corresponding to this identifier. The user may have been deleted."))
                    }
                    
                    it("by only short password") {
                        var onError: Error?
                        viewModel.signIn(with: "", password: "aaa")
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("The email address is badly formatted."))
                    }
                }
                
                context("with google provider") {
                    it("by empty token") {
                        var onError: Error?
                        let credential = GoogleAuthProvider.credential(withIDToken: "", accessToken: "")
                        viewModel.signIn(with: credential)
                        
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                    }
                }
                
                context("with github provider") {
                    it("by empty token") {
                        var onError: Error?
                        let credential = GitHubAuthProvider.credential(withToken: "")
                        viewModel.signIn(with: credential)
                        
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                    }
                }
                
                context("with facebook provider") {
                    it("by empty token") {
                        var onError: Error?
                        let credential = FacebookAuthProvider.credential(withAccessToken: "")
                        viewModel.signIn(with: credential)
                        
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
                        expect(onError).notTo(beNil())
                        expect(onError?.localizedDescription).to(match("An internal error has occurred, print and inspect the error details for more information."))
                    }
                }
            }
        }
    }

}
