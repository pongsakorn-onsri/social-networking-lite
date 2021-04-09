//
//  FeedUseCase.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseFirestore
import Resolver

enum FetchType {
    case new
    case old
}

protocol FeedUseCaseType {
    func getUser() -> Observable<User>
    func fetch(type: FetchType, document: DocumentSnapshot?) -> Single<[Post]>
    func delete(post: Post) -> Single<Bool>
    func signOut() -> Observable<Void>
}

struct FeedUseCaseService: FeedUseCaseType {
    
    @Injected var authenGateway: AuthenGatewayType
    let database = Firestore.firestore()
    let pageSize = 20
    
    func getUser() -> Observable<User> {
        authenGateway.getUser()
    }
    
    func fetch(type: FetchType, document: DocumentSnapshot?) -> Single<[Post]> {
        Single.create { (observer) -> Disposable in
            
            var query = database.collection("posts")
                .order(by: "timestamp", descending: true)
                
            if let cursorDocument = document {
                switch type {
                case .new:
                    query = query.end(beforeDocument: cursorDocument)
                case .old:
                    query = query.start(afterDocument: cursorDocument)
                }
            }
                
            query
                .limit(to: pageSize)
                .getDocuments { (snapshot, error) in
                    guard let documents = snapshot?.documents else {
                        if let error = error {
                            observer(.error(error))
                        } else {
                            observer(.success([])) // prevent no return value
                        }
                        return
                    }
                    let posts = documents.compactMap { Post(with: $0) }
                    observer(.success(posts))
                }
            
            return Disposables.create()
        }
    }
    
    func delete(post: Post) -> Single<Bool> {
        guard let documentId = post.documentId else {
            return .error(FeedUseCaseError.noDocumentId)
        }
        return Single.create { (observer) -> Disposable in
            database.collection("posts")
                .document(documentId)
                .delete { (error) in
                    if let error = error {
                        observer(.error(error))
                    } else {
                        observer(.success(true))
                    }
                }
            return Disposables.create()
        }
    }
    
    func signOut() -> Observable<Void> {
        authenGateway.signOut()
    }
}

enum FeedUseCaseError: LocalizedError {
    case noDocumentId
    
    var localizedDescription: String {
        switch self {
        case .noDocumentId:
            return "No post id"
        }
    }
}
