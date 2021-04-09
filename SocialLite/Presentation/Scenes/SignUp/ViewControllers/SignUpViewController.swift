//
//  RegisterViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit
import MaterialComponents
import Resolver
import RxSwift
import RxCocoa

extension SignUpViewController: UseStoryboard {
    static var storyboardName: String { "SignUp" }
}

class SignUpViewController: UIViewController, UseViewModel {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: MDCOutlinedTextField!
    @IBOutlet weak var passwordTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmPasswordTextField: MDCOutlinedTextField!
    @IBOutlet weak var confirmButton: MDCButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Properties
    typealias Model = SignUpViewModel
    
    let appBarViewController = MDCAppBarViewController()
    var viewModel: SignUpViewModel?
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addChild(appBarViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(appBarViewController.view)
        appBarViewController.didMove(toParent: self)
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
        
        applyTheme(with: containerScheme)
    }
    
    func configureBinding() {
        guard let viewModel = viewModel else { return }
        
        let input = SignUpViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            confirmPassword: confirmPasswordTextField.rx.text.orEmpty.asDriver(),
            submitTrigger: confirmButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        output.$emailValidationMessage
            .asDriver()
            .drive(emailValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$passwordValidationMessage
            .asDriver()
            .drive(passwordValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$confirmPasswordValidationMessage
            .asDriver()
            .drive(confirmPasswordValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(isLoadingBinder)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(loadingView.rx.isAnimating)
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
    
    func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
        emailTextField.applyTheme(withScheme: containerScheme)
        passwordTextField.applyTheme(withScheme: containerScheme)
        confirmPasswordTextField.applyTheme(withScheme: containerScheme)
        confirmButton.applyContainedTheme(withScheme: containerScheme)
    }
}

// MARK: - Binders
extension SignUpViewController {
    var isLoadingBinder: Binder<Bool> {
        return Binder(confirmButton) { button, isLoading in
            button.setTitle(isLoading ? "": "SIGN IN", for: .normal)
        }
    }
    
    var emailValidationMessageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.emailTextField.leadingAssistiveLabel.text = message
            if message.isEmpty {
                vc.emailTextField.applyTheme(withScheme: containerScheme)
            } else {
                vc.emailTextField.applyErrorTheme(withScheme: containerScheme)
            }
        }
    }
    
    var passwordValidationMessageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.passwordTextField.leadingAssistiveLabel.text = message
            if message.isEmpty {
                vc.passwordTextField.applyTheme(withScheme: containerScheme)
            } else {
                vc.passwordTextField.applyErrorTheme(withScheme: containerScheme)
            }
        }
    }
    
    var confirmPasswordValidationMessageBinder: Binder<String> {
        return Binder(self) { vc, message in
            vc.confirmPasswordTextField.leadingAssistiveLabel.text = message
            if message.isEmpty {
                vc.confirmPasswordTextField.applyTheme(withScheme: containerScheme)
            } else {
                vc.confirmPasswordTextField.applyErrorTheme(withScheme: containerScheme)
            }
        }
    }
}
