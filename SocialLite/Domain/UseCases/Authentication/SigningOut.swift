//
//  SigningOut.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift

protocol SigningOut {
    var authenGateway: AuthenGatewayType { get }
}

extension SigningOut {
    func signOut() -> Observable<Void> {
        authenGateway.signOut()
    }
}
