//
//  UserGatewayType.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 8/4/2564 BE.
//

import Foundation
import RxSwift
import FirebaseAuth

protocol AuthenGatewayType {
    func getUser() -> Observable<User>
    func signUp(dto: SignUpDto) -> Observable<User>
    func signIn(dto: SignInDto) -> Observable<User>
    func signIn(with credential: AuthCredential) -> Observable<User>
    func signOut() -> Observable<Void>
}
