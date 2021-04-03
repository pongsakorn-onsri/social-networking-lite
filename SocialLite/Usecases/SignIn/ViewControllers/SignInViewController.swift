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
        signUpButton.rx.tap
            .subscribe(onNext: { [weak self]_ in
                self?.viewModel?.router.trigger(.signup)
            })
            .disposed(by: disposeBag)
        
        signInWithGoogle.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self]_ in
                GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
                GIDSignIn.sharedInstance()?.delegate = self
                GIDSignIn.sharedInstance()?.signIn()
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

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        viewModel?.signIn(with: credential)
    }
}
