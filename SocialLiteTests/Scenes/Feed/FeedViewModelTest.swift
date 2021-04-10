//
//  FeedViewModelTest.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Foundation
import Quick
import Nimble
import RxSwift
import Resolver
import RxTest
import XCoordinator

@testable import SocialLite
final class FeedViewModelTest: QuickSpec {
    typealias ViewModel = FeedViewModel
    
    private var router: WeakRouter<AppRoute>!
    private var useCase: FeedUseCaseMock? { viewModel.useCase as? FeedUseCaseMock }
    private var viewModel: ViewModel!
    private var input: ViewModel.Input!
    private var output: ViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Triggers
    private let signOutTapped = PublishSubject<Void>()
    private let refreshTrigger = PublishSubject<Void>()
    private let loadMoreTrigger = PublishSubject<Void>()
    private let createdPostTrigger = PublishSubject<Void>()
    private let deletePostTrigger = PublishSubject<Post>()
    
    // Outputs
    private var tableData: TestableObserver<[Post]>!
    private var isRefreshing: TestableObserver<Bool>!
    private var isLoadingMore: TestableObserver<Bool>!
    
    override func spec() {
        
        beforeSuite {
            Resolver.main.register { FeedUseCaseMock() as FeedUseCaseType }
        }
        
        describe("As a FeedViewModel") {
            beforeEach {
                self.router = AppCoordinator().weakRouter
                self.viewModel = ViewModel(router: self.router)
                
                self.input = ViewModel.Input(
                    signOutTapped: self.signOutTapped.asDriver(onErrorJustReturn: ()),
                    refreshTrigger: self.refreshTrigger.asDriver(onErrorJustReturn: ()),
                    loadMoreTrigger: self.loadMoreTrigger.asDriver(onErrorJustReturn: ()),
                    createdPostTrigger: self.createdPostTrigger.asDriver(onErrorJustReturn: ()),
                    deletePostTrigger: self.deletePostTrigger.asDriverOnErrorJustComplete()
                )
                
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
                
                self.output = self.viewModel.transform(self.input, disposeBag: self.disposeBag)
                self.tableData = self.scheduler.createObserver([Post].self)
                self.isRefreshing = self.scheduler.createObserver(Bool.self)
                self.isLoadingMore = self.scheduler.createObserver(Bool.self)
                
                self.output.tableData
                    .map { (models) -> [Post] in
                        models.map { $0.items }
                        .map { (items) -> [Post] in
                            items.map { (item) -> Post in
                                switch item {
                                    case let .post(viewModel): return viewModel.post
                                }
                            }
                        }
                        .reduce(into: [Post]()) { (result, posts) in
                            result.append(contentsOf: posts)
                        }
                    }
                    .bind(to: self.tableData)
                    .disposed(by: self.disposeBag)
                self.output.isRefreshing
                    .bind(to: self.isRefreshing)
                    .disposed(by: self.disposeBag)
                self.output.isLoadingMore
                    .bind(to: self.isLoadingMore)
                    .disposed(by: self.disposeBag)
            }
            
            it("get user first") {
                // When
                self.scheduler.start()
                
                // Then
                expect(self.useCase?.getUserCalled).to(beTrue())
                expect(self.useCase?.getPostListCalled).to(beTrue())
            }
            
            it("get post list by refresh") {
                // Given
                let refreshTrigger = self.scheduler.createColdObservable([
                    .next(10, ())
                ])
                // When
                refreshTrigger
                    .bind(to: self.refreshTrigger)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                let tableDataExpected: [Recorded<Event<[Post]>>] = [
                    .next(0, [Post("1"), Post("2"), Post("3"), Post("4"), Post("5")]),
                    .next(10, [Post("1"), Post("2"), Post("3"), Post("4"), Post("5")])
                ]
                
                expect(self.isRefreshing.events) == [.next(0, false),
                                                     .next(10, true),
                                                     .next(10, false)]
                expect(self.useCase?.getPostListCalled).to(beTrue())
                expect(self.tableData.events).to(equal(tableDataExpected))
                
            }
            
            it("get post list by load more") {
                // Given
                let loadMoreTrigger = self.scheduler.createColdObservable([
                    .next(10, ())
                ])
                
                // When
                loadMoreTrigger
                    .bind(to: self.loadMoreTrigger)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                let tableDataExpected: [Recorded<Event<[Post]>>] = [
                    .next(0, [Post("1"), Post("2"), Post("3"), Post("4"), Post("5")]),
                    .next(10, [Post("1"), Post("2"), Post("3"), Post("4"), Post("5"), Post("10"), Post("9"), Post("8")])
                ]
                
                
                expect(self.isLoadingMore.events) == [.next(0, false),
                                                      .next(10, true),
                                                      .next(10, false)]
                expect(self.useCase?.getPostListCalled).to(beTrue())
                expect(self.tableData.events).to(equal(tableDataExpected))
            }
            
            it("call signout") {
                // Given
                let signOutTrigger = self.scheduler.createColdObservable([
                    .next(0, ())
                ])
                // When
                signOutTrigger
                    .bind(to: self.signOutTapped)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                expect(self.isLoadingMore.events) == [.next(0, false)]
                expect(self.useCase?.getPostListCalled).to(beTrue())
            }
            
            it("create post trigger") {
                // Given
                let createdPostTrigger = self.scheduler.createColdObservable([
                    .next(0, ())
                ])
                
                createdPostTrigger
                    .bind(to: self.createdPostTrigger)
                    .disposed(by: self.disposeBag)
                // When
                
                self.scheduler.start()
                
                // Then
                expect(self.isLoadingMore.events) == [.next(0, false)]
                expect(self.useCase?.getPostListCalled).to(beTrue())
            }
            
            it("delete post trigger") {
                // Given
                let deletePostTrigger = self.scheduler.createColdObservable([
                    .next(0, Post("1"))
                ])
                
                // When
                deletePostTrigger
                    .bind(to: self.deletePostTrigger)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                expect(self.isLoadingMore.events) == [.next(0, false)]
                expect(self.useCase?.getPostListCalled).to(beTrue())
            }
        }
    }
}
