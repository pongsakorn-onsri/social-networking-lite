//
//  CreatePostViewModelTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxTest
import XCoordinator
import Resolver

@testable import SocialLite
class CreatePostViewModelTest: QuickSpec {
    private var viewModel: CreatePostViewModel!
    private var router: WeakRouter<AppRoute>!
    private var user: User!
    private var useCase: CreatePostUseCaseMock? { viewModel.useCase as? CreatePostUseCaseMock }
    private var delegate: PublishSubject<Post>!
    private var input: CreatePostViewModel.Input!
    private var output: CreatePostViewModel.Output!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // Outputs
    private var countingTextOutput: TestableObserver<String>!
    private var isLoadingOutput: TestableObserver<Bool>!
    private var validateMessageOutput: TestableObserver<String>!
    
    // Triggers
    private let textInputTrigger = PublishSubject<String>()
    private let closeTrigger = PublishSubject<Void>()
    private let createTrigger = PublishSubject<Void>()
    
    override func spec() {
        
        beforeSuite {
            Resolver.main.register { CreatePostUseCaseMock() as CreatePostUseCaseType }
        }
        
        describe("As a CreatePostViewModel") {
            beforeEach {
                self.router = AppCoordinator().weakRouter
                self.user = User(uid: "test", providerID: "test")
                self.delegate = PublishSubject()
                self.viewModel = CreatePostViewModel(
                    router: self.router,
                    user: self.user,
                    delegate: self.delegate
                )
                
                self.input = CreatePostViewModel.Input(
                    textInput: self.textInputTrigger.asDriverOnErrorJustComplete(),
                    closeTapped: self.closeTrigger.asDriverOnErrorJustComplete(),
                    createTapped: self.createTrigger.asDriverOnErrorJustComplete()
                )
                
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
                
                self.output = self.viewModel.transform(self.input, disposeBag: self.disposeBag)
                
                self.countingTextOutput = self.scheduler.createObserver(String.self)
                self.isLoadingOutput = self.scheduler.createObserver(Bool.self)
                self.validateMessageOutput = self.scheduler.createObserver(String.self)
                
                self.output.$countingText
                    .subscribe(self.countingTextOutput)
                    .disposed(by: self.disposeBag)
                self.output.$isLoading
                    .subscribe(self.isLoadingOutput)
                    .disposed(by: self.disposeBag)
                self.output.$validateMessage
                    .subscribe(self.validateMessageOutput)
                    .disposed(by: self.disposeBag)
            }
            
            it("validate post") {
                // Given
                let inputTrigger = self.scheduler.createColdObservable([
                    .next(0, "")
                ])
                
                let createTrigger = self.scheduler.createColdObservable([
                    .next(10, ())
                ])
                
                // When
                inputTrigger
                    .bind(to: self.textInputTrigger)
                    .disposed(by: self.disposeBag)
                
                createTrigger
                    .bind(to: self.createTrigger)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                let countingTextExpected: [Recorded<Event<String>>] = [
                    .next(0, "0 / 1024"),
                    .next(0, "0 / 1024")
                ]
                let validateMessageExpected: [Recorded<Event<String>>] = [
                    .next(0, ""),
                    .next(10, "Please input your content.")
                ]
                
                expect(self.countingTextOutput.events).to(equal(countingTextExpected))
                expect(self.validateMessageOutput.events).to(equal(validateMessageExpected))
                expect(self.useCase?.validatePostCalled).to(beTrue())
            }
            
            it("can create post") {
                // Given
                let inputTrigger = self.scheduler.createColdObservable([
                    .next(0, "test")
                ])
                
                let createTrigger = self.scheduler.createColdObservable([
                    .next(10, ())
                ])
                
                // When
                inputTrigger
                    .bind(to: self.textInputTrigger)
                    .disposed(by: self.disposeBag)
                
                createTrigger
                    .bind(to: self.createTrigger)
                    .disposed(by: self.disposeBag)
                
                let delegateTriggered = self.scheduler.record(self.delegate)
                
                self.scheduler.start()
                
                // Then
                let delegateExpected: [Recorded<Event<Post>>] = [
                    .next(10, Post(userId: "test", displayName: "Anonymous", content: "test", timestamp: Date()))
                ]
                
                expect(self.countingTextOutput.events).to(equal([ .next(0, "0 / 1024"),
                                                                  .next(0, "4 / 1024") ]))
                expect(self.validateMessageOutput.events).to(equal([ .next(0, ""),
                                                                     .next(10, "") ]))
                expect(self.useCase?.createPostCalled).to(beTrue())
                expect(delegateTriggered.events).to(equal(delegateExpected))
            }
            
            it("cannot create post with rude word") {
                // Given
                let inputTrigger = self.scheduler.createColdObservable([
                    .next(0, "hello fucking")
                ])
                
                let createTrigger = self.scheduler.createColdObservable([
                    .next(10, ())
                ])
                
                // When
                inputTrigger
                    .bind(to: self.textInputTrigger)
                    .disposed(by: self.disposeBag)
                
                createTrigger
                    .bind(to: self.createTrigger)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                let countingTextExpected: [Recorded<Event<String>>] = [
                    .next(0, "0 / 1024"),
                    .next(0, "13 / 1024")
                ]
                let validateMessageExpected: [Recorded<Event<String>>] = [
                    .next(0, ""),
                    .next(10, "Found rude words. Please change your text.")
                ]
                
                expect(self.countingTextOutput.events).to(equal(countingTextExpected))
                expect(self.validateMessageOutput.events).to(equal(validateMessageExpected))
                expect(self.useCase?.createPostCalled).to(beFalse())
            }
            
            it("cannot create post with exceed than 1024 words") {
                // Given
                let inputTrigger = self.scheduler.createColdObservable([
                    .next(0, "hello fucking"),
                    .next(100, Array(repeating: "s", count: 1025).joined())
                ])
                
                let createTrigger = self.scheduler.createColdObservable([
                    .next(10, ()),
                    .next(110, ())
                ])
                
                // When
                inputTrigger
                    .bind(to: self.textInputTrigger)
                    .disposed(by: self.disposeBag)
                
                createTrigger
                    .bind(to: self.createTrigger)
                    .disposed(by: self.disposeBag)
                
                self.scheduler.start()
                
                // Then
                let countingTextExpected: [Recorded<Event<String>>] = [
                    .next(0, "0 / 1024"),
                    .next(0, "13 / 1024"),
                    .next(100, "1025 / 1024")
                ]
                let validateMessageExpected: [Recorded<Event<String>>] = [
                    .next(0, ""),
                    .next(10, "Found rude words. Please change your text."),
                    .next(110, "Text input exceed limit 1024 charactors.")
                ]
                
                expect(self.countingTextOutput.events).to(equal(countingTextExpected))
                expect(self.validateMessageOutput.events).to(equal(validateMessageExpected))
                expect(self.useCase?.createPostCalled).to(beFalse())
            }
        }
    }
}
