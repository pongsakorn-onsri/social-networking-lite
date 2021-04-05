//
//  User.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 5/4/2564 BE.
//

import Foundation
import FirebaseAuth

protocol UserAccount {
    var providerID: String { get set }
    var uid: String { get set }
}

public class User: UserAccount {
    var providerID: String
    var uid: String
    var displayName: String?
    var email: String?
    var photoUrl: URL?
    var phoneNumber: String?
    
    init(uid: String, providerID: String) {
        self.uid = uid
        self.providerID = providerID
    }
    
    init?(firebaseUser: FirebaseAuth.User?) {
        guard let user = firebaseUser else { return nil }
        self.providerID = user.providerID
        self.uid = user.uid
        self.displayName = user.displayName
        self.email = user.email
        self.photoUrl = user.photoURL
        self.phoneNumber = user.phoneNumber
    }
    
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.uid == rhs.uid
    }
}
