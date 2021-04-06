//
//  Post.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import Foundation
import ObjectMapper
import FirebaseFirestore

struct Post {
    var userId: String
    var displayName: String
    var content: String
    var timestamp: Timestamp
    
    init(userId: String, displayName: String, content: String, timestamp: Date) {
        self.userId = userId
        self.displayName = displayName
        self.content = content
        self.timestamp = Timestamp(date: timestamp)
    }
}

extension Post {
    func toJSON() -> [String: Any] {
        [
            "author_id": userId,
            "display_name": displayName,
            "content": content,
            "timestamp": timestamp
        ]
    }
}
