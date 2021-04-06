//
//  CreatePostUseCase.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import Foundation
import RxSwift

protocol CreatePostUseCase {
    func create(content: String) -> Single<Post>
}

struct CreatePostService: CreatePostUseCase {
    
    var user: User?
    
    func create(content: String) -> Single<Post> {
        guard let user = user else {
            return .error(CreatePostError.userNotFound)
        }
        if content.contains("fucking") {
            return .error(CreatePostError.foundRudeWords)
        }
        let newPost = Post(userId:  user.uid, content: content, timestamp: Date())
        return .just(newPost)
    }
}

enum CreatePostError: Error {
    case userNotFound
    case textInputEmpty
    case textInputExceed
    case foundRudeWords
}

extension CreatePostError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userNotFound: return "User not found ❌"
        case .textInputEmpty: return "Please input your content."
        case .textInputExceed: return "Text input exceed limit 1024 charactors."
        case .foundRudeWords: return "Found rude words. Please change your text."
        }
    }
}
