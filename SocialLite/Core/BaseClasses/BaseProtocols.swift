//
//  BaseProtocol.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import UIKit

public protocol UseViewModel {
    associatedtype Model
    var viewModel: Model? { get set }
    mutating func bind(to model: Model)
}

public protocol UseStoryboard {
    static var storyboardName: String { get }
    static var storyboardIdentifier: String { get }
}

public extension UseStoryboard where Self: UIViewController {
    static var storyboardIdentifier: String { return String(describing: Self.self) }
}

public extension UseViewModel where Self: UIViewController, Self: UseStoryboard {
    static func newInstance(with viewModel: Model) -> Self {
        let storyboard = UIStoryboard(name: Self.storyboardName, bundle: Bundle.main)
        let vcIdentifier = Self.storyboardIdentifier
        let instantiateVC = storyboard.instantiateViewController(withIdentifier: vcIdentifier)
        if var viewController = instantiateVC as? Self {
            viewController.bind(to: viewModel)
            return viewController
        } else {
            return Self()
        }
    }
}

public extension UseViewModel {
    mutating func bind(to model: Model) {
        self.viewModel = model
    }
}
