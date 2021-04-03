//
//  LoginViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Firebase
import FirebaseAuth
import GoogleSignIn
import MaterialComponents

extension SignInViewController: UseStoryboard {
    static var storyboardName: String { "SignIn" }
}

final class SignInViewController: BaseViewController<SignInViewModel> {
    
    @IBOutlet weak var emailTextField: MDCOutlinedTextField!
    @IBOutlet weak var passwordTextField: MDCOutlinedTextField!
    
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var signUpButton: MDCButton!
    @IBOutlet weak var signInWithGoogle: GIDSignInButton!
    
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
        configureSignInProviders()
        configureBinding()
    }
    
    func configureUI() {
        appBarViewController.navigationBar.title = "Sign In"
        
        emailTextField.label.text = "Email account"
        emailTextField.placeholder = "john.doe@email.com"
        emailTextField.sizeToFit()
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.label.text = "Password"
        passwordTextField.placeholder = "*********"
        passwordTextField.sizeToFit()
        
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.accessibilityLabel = "Sign in"
        
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.accessibilityLabel = "Sign Up"
        
        applyTheme(with: containerScheme)
    }
    
    func configureBinding() {
        guard let viewModel = viewModel else { return }
        
        let input = SignInViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            signInTapped: signInButton.rx.tap.asObservable(),
            signUpTapped: signUpButton.rx.tap.asObservable(),
            signInGoogleTapped: signInWithGoogle.rx.tapGesture()
                .when(.recognized)
                .map { _ in Void() }
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.emailError
            .drive(onNext: { [weak self]error in
                if let error = error {
                    self?.emailTextField.leadingAssistiveLabel.text = error.localizedDescription
                    self?.emailTextField.applyErrorTheme(withScheme: containerScheme)
                } else {
                    self?.emailTextField.leadingAssistiveLabel.text = nil
                    self?.emailTextField.applyTheme(withScheme: containerScheme)
                }
            })
            .disposed(by: disposeBag)
        
        output.passwordError
            .drive(onNext: { [weak self]error in
                if let error = error {
                    self?.passwordTextField.leadingAssistiveLabel.text = error.localizedDescription
                    self?.passwordTextField.applyErrorTheme(withScheme: containerScheme)
                } else {
                    self?.passwordTextField.leadingAssistiveLabel.text = nil
                    self?.passwordTextField.applyTheme(withScheme: containerScheme)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func configureSignInProviders() {
        // Google
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
        emailTextField.applyTheme(withScheme: containerScheme)
        passwordTextField.applyTheme(withScheme: containerScheme)
        signInButton.applyOutlinedTheme(withScheme: containerScheme)
        signUpButton.applyOutlinedTheme(withScheme: containerScheme)
    }
}
