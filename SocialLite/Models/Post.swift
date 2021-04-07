//
//  Post.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 6/4/2564 BE.
//

import Foundation
import ObjectMapper
import FirebaseFirestore

public struct Post: Hashable {
    var userId: String
    var displayName: String
    var content: String
    var timestamp: Timestamp
    var document: QueryDocumentSnapshot?
    var documentId: String?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(documentId)
    }
    
    init(userId: String, displayName: String, content: String, timestamp: Date) {
        self.userId = userId
        self.displayName = displayName
        self.content = content
        self.timestamp = Timestamp(date: timestamp)
    }
    
    init?(with document: QueryDocumentSnapshot) {
        let jsonData = document.data()
        guard let userId = jsonData["author_id"] as? String,
              let displayName = jsonData["display_name"] as? String,
              let content = jsonData["content"] as? String,
              let timestamp = jsonData["timestamp"] as? Timestamp else {
            return nil
        }
        self.init(userId: userId, displayName: displayName, content: content, timestamp: timestamp.dateValue())
        self.document = document
        documentId = document.documentID
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

extension Array where Element == Post {
    func withoutDuplicates() -> [Element] {
        reduce(into: [Element]()) { (result, element) in
            if !result.contains(where: { $0.documentId == element.documentId }) {
                result.append(element)
            }
        }
    }
}
