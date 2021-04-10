//
//  FeedViewControllerTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import Resolver

@testable import SocialLite
class FeedViewControllerTests: QuickSpec {
    
    var viewController: FeedViewController!

    override func spec() {
        
        beforeSuite {
            Resolver.main.register { FeedUseCaseMock() as FeedUseCaseType }
        }
        
        describe("As a FeedViewController") {
            beforeEach {
                let router = AppCoordinator().weakRouter
                let viewModel = FeedViewModel(router: router)
                self.viewController = FeedViewController.newInstance(with: viewModel)
            }
            
            it("has IBOutlets") {
                _ = self.viewController.view
                
                expect(self.viewController.tableView).toNot(beNil())
            }
            
            it("has viewModel") {
                _ = self.viewController.view
                
                expect(self.viewController.viewModel).toNot(beNil())
            }
        }
    }
}
