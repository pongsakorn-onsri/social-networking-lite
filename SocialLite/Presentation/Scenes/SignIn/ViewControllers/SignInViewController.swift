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

final class SignInViewController: UIViewController, UseViewModel {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: MDCOutlinedTextField!
    @IBOutlet weak var passwordTextField: MDCOutlinedTextField!
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var signUpButton: MDCButton!
    @IBOutlet weak var signInWithGoogle: GIDSignInButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    let appBarViewController = MDCAppBarViewController()
    var viewModel: SignInViewModel?
    var disposeBag = DisposeBag()
    
    private var signInTrigger = PublishSubject<AuthCredential>()
    
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
        configureSignInProviders()
        configureBinding()
    }
    
    func configureUI() {
        appBarViewController.navigationBar.title = "Sign In"
        
        emailTextField.label.text = "Email account"
        emailTextField.placeholder = "john.doe@email.com"
        emailTextField.keyboardType = .emailAddress
        emailTextField.sizeToFit()
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.label.text = "Password"
        passwordTextField.placeholder = "*********"
        passwordTextField.returnKeyType = .done
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
            email: emailTextField.rx.text.orEmpty.asDriver(),
            password: passwordTextField.rx.text.orEmpty.asDriver(),
            signInTapped: signInButton.rx.tap.asDriver(),
            signUpTapped: signUpButton.rx.tap.asDriver(),
            signInGoogle: signInTrigger.asDriverOnErrorJustComplete()
        )
        
        signInWithGoogle.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
                GIDSignIn.sharedInstance()?.signIn()
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$emailValidationMessage
            .asDriver()
            .drive(emailValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$passwordValidationMessage
            .asDriver()
            .drive(passwordValidationMessageBinder)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
            
        output.$isLoading
            .asDriver()
            .drive(isLoadingBinder)
            .disposed(by: disposeBag)
    }
    
    func configureSignInProviders() {
        // Google
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
        emailTextField.applyTheme(withScheme: containerScheme)
        passwordTextField.applyTheme(withScheme: containerScheme)
        signInButton.applyOutlinedTheme(withScheme: containerScheme)
        signUpButton.applyOutlinedTheme(withScheme: containerScheme)
    }
}

// MARK: - Binders
extension SignInViewController {
    var isLoadingBinder: Binder<Bool> {
        return Binder(signInButton) { button, isLoading in
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
}

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        signInTrigger.onNext(credential)
    }
}
