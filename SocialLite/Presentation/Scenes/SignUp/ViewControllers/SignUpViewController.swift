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
        configureBinding()
    }
    
    func configureUI() {
        appBarViewController.navigationBar.title = "Sign Up"
        
        emailTextField.label.text = "Email account"
        emailTextField.placeholder = "john.doe@email.com"
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        emailTextField.sizeToFit()
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.label.text = "Password"
        passwordTextField.placeholder = "*********"
        passwordTextField.textContentType = .newPassword
        passwordTextField.returnKeyType = .done
        passwordTextField.passwordRules = UITextInputPasswordRules(descriptor: "minlength: 8;")
        passwordTextField.sizeToFit()
        
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.label.text = "Confirm Password"
        confirmPasswordTextField.placeholder = "*********"
        confirmPasswordTextField.textContentType = .newPassword
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.sizeToFit()
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.accessibilityLabel = "Confirm"
    }
    
    func configureBinding() {
        guard let viewModel = viewModel else { return }
        let input = SignUpViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            confirmPassword: confirmPasswordTextField.rx.text.orEmpty.asObservable(),
            submitTapped: confirmButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        output.emailError
            .map { (self.emailTextField, $0) }
            .drive(onNext: handleTextFieldOnError)
            .disposed(by: disposeBag)
        
        output.passwordError
            .map { (self.passwordTextField, $0) }
            .drive(onNext: handleTextFieldOnError)
            .disposed(by: disposeBag)
        
        output.confirmPasswordError
            .map { (self.confirmPasswordTextField, $0) }
            .drive(onNext: handleTextFieldOnError)
            .disposed(by: disposeBag)
    }
    
    private func handleTextFieldOnError(_ textField: MDCOutlinedTextField?, _ error: Error?) {
        if let error = error {
            textField?.leadingAssistiveLabel.text = error.localizedDescription
            textField?.applyErrorTheme(withScheme: containerScheme)
        } else {
            textField?.leadingAssistiveLabel.text = nil
            textField?.applyTheme(withScheme: containerScheme)
        }
    }
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
        emailTextField.applyTheme(withScheme: containerScheme)
        passwordTextField.applyTheme(withScheme: containerScheme)
        confirmPasswordTextField.applyTheme(withScheme: containerScheme)
        confirmButton.applyContainedTheme(withScheme: containerScheme)
    }
}

