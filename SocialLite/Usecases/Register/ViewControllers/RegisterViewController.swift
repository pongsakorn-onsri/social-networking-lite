//
//  RegisterViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit
import MaterialComponents

extension RegisterViewController: UseStoryboard {
    static var storyboardName: String { "Register" }
}

class RegisterViewController: BaseViewController<RegisterViewModel> {

    let appBarViewController = MDCAppBarViewController()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addChild(appBarViewController)
    }
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(appBarViewController.view)
        appBarViewController.didMove(toParent: self)
        super.viewDidLoad()
    }
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
    }
}

