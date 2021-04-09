//
//  PostGateway.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 9/4/2564 BE.
//

import Foundation
import FirebaseFirestore
import RxSwift

struct PostGateway: PostGatewayType {
    
    let database = Firestore.firestore()
    
    func getPostList(dto: GetPostListDto) -> Observable<[Post]> {
        return .just([])
    }
    
    func createPost(dto: CreatePostDto) -> Observable<Post> {
        return Observable.create { (observer) -> Disposable in
            let data = dto.post?.toJSON() ?? [:]
            var reference: DocumentReference? = nil
            reference = database
                .collection("posts")
                .addDocument(data: data) { (error) in
                    if let error = error {
                        observer.onError(error)
                    } else if var newPost = dto.post {
                        newPost.documentId = reference?.documentID
                        observer.onNext(newPost)
                    }
                    observer.onCompleted()
                }
            
            return Disposables.create()
        }
    }
    
    func removePost(_ dto: DeletePostDto) -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            database.collection("posts")
                .document(dto.documentId)
                .delete { (error) in
                    if let error = error {
                        observer.onError(error)
                    } else {
                        observer.onNext(())
                    }
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
}
