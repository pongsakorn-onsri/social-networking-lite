//
//  DeletingPost.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift

struct DeletePostDto {
    var documentId: String
    
    init(id: String) {
        documentId = id
    }
}

protocol DeletingPost {
    var postGateway: PostGatewayType { get }
}

extension DeletingPost {
    func removePost(_ post: DeletePostDto) -> Observable<Void> {
        return postGateway.removePost(post)
    }
    
}
