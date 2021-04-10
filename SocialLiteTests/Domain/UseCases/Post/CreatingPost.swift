//
//  CreatingPost.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import RxSwift
import RxTest

@testable import SocialLite
class CreatingPostListTest: QuickSpec, CreatingPost {
    var postGateway: PostGatewayType {
        postGatewayMock
    }
    
    private var postGatewayMock: PostGatewayMock!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    override func spec() {
        describe("As a CreatingPost") {
            beforeEach {
                self.postGatewayMock = PostGatewayMock()
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
            }
            
            it("can validate post") {
                var post = Post(userId: "", displayName: "", content: "", timestamp: Date())
                expect(self.validate(post).firstMessage).to(match("Please input your content."))
                expect(self.validate(post).isValid).to(beFalse())
                
                post = Post(userId: "", displayName: "", content: "fucking", timestamp: Date())
                expect(self.validate(post).firstMessage).to(match("Found rude words. Please change your text."))
                expect(self.validate(post).isValid).to(beFalse())
                
                let content = """
                    Resolver icon
                    An ultralight Dependency Injection / Service Locator framework for Swift 5.2 on iOS.

                    Note that several recent updates to Resolver may break earlier code that used argument passing and/or named services. For more see the Updates section below.

                    Introduction
                    Dependency Injection frameworks support the Inversion of Control design pattern. Technical definitions aside, dependency injection pretty much boils down to:

                    | Giving an object the things it needs to do its job.

                    That's it. Dependency injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and to test.

                    For more, see: A Gentle Introduction to Dependency Injection.

                    Dependency Injection Strategies
                    There are six classic dependency injection strategies:

                    Interface Injection
                    Property Injection
                    Constructor Injection
                    Method Injection
                    Service Locator
                    Annotation (NEW)
                    Resolver supports them all. Follow the links for a brief description, examples, and the pros and cons of each.

                    Property Wrappers
                    Speaking of Annotations, Resolver now supports resolving services using the new property wrapper syntax in Swift 5.1.
                """
                post = Post(userId: "", displayName: "", content: content, timestamp: Date())
                expect(self.validate(post).firstMessage).to(match("Text input exceed limit 1024 charactors."))
                expect(self.validate(post).isValid).to(beFalse())
                
                post = Post(userId: "", displayName: "", content: "test post", timestamp: Date())
                expect(self.validate(post).firstMessage) == ""
                expect(self.validate(post).isValid).to(beTrue())
            }
            
            it("cannot create post with error empty string") {
                let post = Post(userId: "", displayName: "", content: "", timestamp: Date())
                let dto = CreatePostDto(post: post)
                let createPostObserver = self.scheduler.createObserver(Post.self)
                
                self.createPost(dto)
                    .subscribe(createPostObserver)
                    .disposed(by: self.disposeBag)
                
                expect(createPostObserver.events.last?.value.error).toNot(beNil())
                expect(self.postGatewayMock.createPostCalled).to(beFalse())
            }
            
            it("can create post") {
                let post = Post(userId: "", displayName: "", content: "test", timestamp: Date())
                let dto = CreatePostDto(post: post)
                let createPostObserver = self.scheduler.createObserver(Post.self)
                
                self.createPost(dto)
                    .subscribe(createPostObserver)
                    .disposed(by: self.disposeBag)
                
                expect(self.postGatewayMock.createPostCalled).to(beTrue())
            }
        }
    }

}
