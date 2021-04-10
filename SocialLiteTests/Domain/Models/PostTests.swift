//
//  PostTests.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import XCTest
import Quick
import Nimble
import FirebaseFirestore

@testable import SocialLite
class PostTests: QuickSpec {

    override func spec() {
        describe("As a Post model") {
            var post: Post!
            
            context("can initialize") {
                it("with firestore document snapshot") {
                    // QueryDocumentSnapshot cannot created directly
                }
                
                context("with local") {
                    
                    var postDate: Date!
                    
                    beforeEach {
                        postDate = Date()
                        post = Post(userId: "local", displayName: "pongsakorn", content: "test", timestamp: postDate)
                    }
                    
                    it("has values expected") {
                        expect(post).notTo(beNil())
                        expect(post.userId).to(match("local"))
                        expect(post.displayName).to(match("pongsakorn"))
                        expect(post.content).to(match("test"))
                    }
                    
                    it("can export to be JSON") {
                        let json = post.toJSON()
                        
                        expect(json["author_id"] as? String).to(match("local"))
                        expect(json["display_name"] as? String).to(match("pongsakorn"))
                        expect(json["content"] as? String).to(match("test"))
                        expect(json["timestamp"] as? Timestamp) == Timestamp(date: postDate)
                    }
                }
            }
            
            it("can filter without duplicate") {
                var mockPost = Post(userId: "", displayName: "", content: "", timestamp: Date())
                mockPost.documentId = "1"
                
                var posts = Array(arrayLiteral: mockPost, mockPost, mockPost, mockPost, mockPost)
                posts[2].documentId = "3"
                
                let result = posts.withoutDuplicates()
                
                expect(result).to(haveCount(2))
            }
            
            it("hasher") {
                post = Post(userId: "", displayName: "", content: "", timestamp: Date())
                post.documentId = "123456"
                var hasher = Hasher()
                post.hash(into: &hasher)
                
                expect(hasher.finalize()).to(equal(post.hashValue))
            }
        }
    }

}

extension Post {
    init(_ id: String) {
        self.init(userId: "test", displayName: "test_user", content: "", timestamp: Date())
        self.documentId = id
    }
}
