//
//  SignUpViewControllerTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import Resolver
import RxSwift

@testable import SocialLite
class SignUpViewControllerTests: QuickSpec {
    
    var viewController: SignUpViewController!

    override func spec() {

        beforeSuite {
            Resolver.main.register { SignUpUseCaseMock() as SignUpUseCaseType }
        }
        
        describe("As a SignUpViewController") {
            beforeEach {
                let router = AuthenticateCoordinator().weakRouter
                let delegate = PublishSubject<User>()
                let viewModel = SignUpViewModel(router: router, delegate: delegate)
                self.viewController = SignUpViewController.newInstance(with: viewModel)
            }
            
            it("has IBOutlets") {
                _ = self.viewController.view
                
                expect(self.viewController.emailTextField).toNot(beNil())
                expect(self.viewController.passwordTextField).toNot(beNil())
                expect(self.viewController.confirmPasswordTextField).toNot(beNil())
                expect(self.viewController.confirmButton).toNot(beNil())
                expect(self.viewController.loadingView).toNot(beNil())
            }
            
            it("has viewModel") {
                _ = self.viewController.view
                
                expect(self.viewController.viewModel).toNot(beNil())
            }
        }
    }
    
}
