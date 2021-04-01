//
//  RegisterViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit

class RegisterViewController: BaseViewController<RegisterViewModel> {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RegisterViewController: UseStoryboard {
    static var storyboardName: String { "Register" }
}
