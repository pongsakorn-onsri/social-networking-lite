//
//  DeletingPost.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import RxSwift
import RxTest

@testable import SocialLite
class DeletingPostListTest: QuickSpec, DeletingPost {
    var postGateway: PostGatewayType {
        postGatewayMock
    }
    
    private var postGatewayMock: PostGatewayMock!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    override func spec() {
        describe("As a DeletingPost") {
            beforeEach {
                self.postGatewayMock = PostGatewayMock()
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
            }
            
            it("can remove post") {
                // Given
                let dto = DeletePostDto(id: "1234")
                let deletePostObserver = self.scheduler.createObserver(Void.self)
                
                // When
                self.removePost(dto)
                    .subscribe(deletePostObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                
                expect(self.postGatewayMock.removePostCalled).to(beTrue())
            }
        }
    }

}
