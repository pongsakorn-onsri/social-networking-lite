//
//  BaseViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import UIKit
import RxSwift

open class BaseViewController<T: ViewModelProtocol>: UIViewController, UseViewModel {
    public typealias Model = T
    
    open var viewModel: Model?
    public let disposeBag = DisposeBag()
    
    public func bind(to model: T) {
        self.viewModel = model
    }
}
