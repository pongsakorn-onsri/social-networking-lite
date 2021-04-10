//
//  SigningOutTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 10/4/2564 BE.
//

import Quick
import Nimble
import RxSwift
import RxTest

@testable import SocialLite
class SigningOutTests: QuickSpec, SigningOut {

    var authenGateway: AuthenGatewayType {
        authenMock
    }
    
    private var authenMock: MockAuthen!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    override func spec() {
        describe("As a SigningOut") {
            beforeEach {
                self.authenMock = MockAuthen()
                self.disposeBag = DisposeBag()
                self.scheduler = TestScheduler(initialClock: 0)
            }
            
            it("can sign out") {
                // Given
                let signoutObserver = self.scheduler.createObserver(Void.self)
                
                // When
                self.signOut()
                    .subscribe(signoutObserver)
                    .disposed(by: self.disposeBag)
                
                // Then
                expect(self.authenMock.signOutCalled).to(beTrue())
            }
        }
    }

}
