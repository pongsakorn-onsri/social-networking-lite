//
//  GettingPostListTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import RxSwift
import RxTest

@testable import SocialLite
class GettingPostListTest: QuickSpec, GettingPostList {
    var postGateway: PostGatewayType {
        postGatewayMock
    }
    
    private var postGatewayMock: PostGatewayMock!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    override func spec() {
        describe("As a GettingPostList") {
            beforeEach {
                self.postGatewayMock = PostGatewayMock()
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
            }
            
            it("can get default post") {
                // Given
                let dto = GetPostListDto()
                let postsObserver = self.scheduler.createObserver([Post].self)
                
                // When
                self.getPostList(dto: dto)
                    .subscribe(postsObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                expect(postsObserver.events.first?.value.element).to(haveCount(5))
                expect(self.postGatewayMock.getPostListCalled).to(beTrue())
            }
            
            it("can get new post") {
                // Given
                let dto = GetPostListDto(type: .new, document: nil)
                let postsObserver = self.scheduler.createObserver([Post].self)
                
                // When
                self.getPostList(dto: dto)
                    .subscribe(postsObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                expect(postsObserver.events.first?.value.element).to(haveCount(5))
                expect(self.postGatewayMock.getPostListCalled).to(beTrue())
            }
            
            it("can get old post") {
                // Given
                let dto = GetPostListDto(type: .old, document: nil)
                let postsObserver = self.scheduler.createObserver([Post].self)
                
                // When
                self.getPostList(dto: dto)
                    .subscribe(postsObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                expect(postsObserver.events.first?.value.element).to(haveCount(3))
                expect(self.postGatewayMock.getPostListCalled).to(beTrue())
            }
        }
    }

}
