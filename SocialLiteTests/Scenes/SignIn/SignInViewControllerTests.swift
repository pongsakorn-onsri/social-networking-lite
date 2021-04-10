//
//  SignInViewControllerTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import Resolver
import RxSwift

@testable import SocialLite
class SignInViewControllerTests: QuickSpec {
    
    var viewController: SignInViewController!

    override func spec() {

        beforeSuite {
            Resolver.main.register { SignInUseCaseMock() as SignInUseCaseType }
        }
        
        describe("As a SignInViewController") {
            beforeEach {
                let router = AuthenticateCoordinator().weakRouter
                let delegate = PublishSubject<User>()
                let viewModel = SignInViewModel(router: router, delegate: delegate)
                self.viewController = SignInViewController.newInstance(with: viewModel)
            }
            
            it("has IBOutlets") {
                _ = self.viewController.view
                
                expect(self.viewController.emailTextField).toNot(beNil())
                expect(self.viewController.passwordTextField).toNot(beNil())
                expect(self.viewController.signInButton).toNot(beNil())
                expect(self.viewController.signUpButton).toNot(beNil())
                expect(self.viewController.signInWithGoogle).toNot(beNil())
                expect(self.viewController.loadingView).toNot(beNil())
            }
            
            it("has viewModel") {
                _ = self.viewController.view
                
                expect(self.viewController.viewModel).toNot(beNil())
            }
        }
    }
    
}
