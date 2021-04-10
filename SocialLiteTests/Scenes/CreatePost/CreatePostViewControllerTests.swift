//
//  CreatePostViewControllerTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import XCTest
import Quick
import Nimble
import RxSwift
import Resolver

@testable import SocialLite
final class CreatePostViewControllerTests: QuickSpec {

    var viewController: CreatePostViewController!
    
    override func spec() {
        
        beforeSuite {
            Resolver.main.register { CreatePostUseCaseMock() as CreatePostUseCaseType }
        }
        
        describe("As a CreatePostViewController") {
            
            beforeEach {
                let router = AppCoordinator().weakRouter
                let user = User(uid: "test_user", providerID: "test")
                let delegate = PublishSubject<Post>()
                let viewModel = CreatePostViewModel(router: router, user: user, delegate: delegate)
                self.viewController = CreatePostViewController.newInstance(with: viewModel)
            }
            
            it("has IBOutlets") {
                _ = self.viewController.view
                
                expect(self.viewController.loadingIndicator).toNot(beNil())
                expect(self.viewController.closeButton).toNot(beNil())
                expect(self.viewController.createButton).toNot(beNil())
                expect(self.viewController.textArea).toNot(beNil())
            }
            
            it("has viewModel") {
                _ = self.viewController.view
                
                expect(self.viewController.viewModel).toNot(beNil())
            }
        }
    }

}
