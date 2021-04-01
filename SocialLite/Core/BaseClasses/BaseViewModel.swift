//
//  BaseViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import RxSwift
import XCoordinator

public protocol ViewModelProtocol {
    associatedtype RouteType: Route
    var router: WeakRouter<RouteType> { get }
    var disposeBag: DisposeBag { get set }
    init(with router: WeakRouter<RouteType>)
}

public class BaseViewModel: NSObject, ViewModelProtocol {
    public typealias RouteType = AppRoute
    public var router: WeakRouter<RouteType>
    public var disposeBag: DisposeBag = DisposeBag()

    required public init(with router: WeakRouter<RouteType>) {
        self.router = router
    }
}
