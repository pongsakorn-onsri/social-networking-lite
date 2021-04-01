//
//  LoginViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController<LoginViewModel> {
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBinding()
    }
    
    func configureBinding() {
        registerButton.rx.tap
            .subscribe(onNext: { [weak self]_ in
                self?.viewModel?.routeToRegister()
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewController: UseStoryboard {
    static var storyboardName: String { "Login" }
}
