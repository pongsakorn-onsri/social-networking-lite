//
//  RegisterViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit
import MaterialComponents

extension SignUpViewController: UseStoryboard {
    static var storyboardName: String { "SignUp" }
}

class SignUpViewController: BaseViewController<SignUpViewModel> {

    @IBOutlet weak var emailTextField: MDCOutlinedTextField!
    @IBOutlet weak var passwordTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmPasswordTextField: MDCOutlinedTextField!
    
    @IBOutlet weak var confirmButton: MDCButton!
    
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
        configureUI()
    }
    
    func configureUI() {
        appBarViewController.navigationBar.title = "Sign Up"
        
        emailTextField.label.text = "Email account"
        emailTextField.placeholder = "john.doe@email.com"
        emailTextField.sizeToFit()
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.label.text = "Password"
        passwordTextField.placeholder = "*********"
        passwordTextField.sizeToFit()
        
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.label.text = "Confirm Password"
        confirmPasswordTextField.placeholder = "*********"
        confirmPasswordTextField.sizeToFit()
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.accessibilityLabel = "Confirm"
    }
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
        emailTextField.applyTheme(withScheme: containerScheme)
        passwordTextField.applyTheme(withScheme: containerScheme)
        confirmPasswordTextField.applyTheme(withScheme: containerScheme)
        confirmButton.applyContainedTheme(withScheme: containerScheme)
    }
}

