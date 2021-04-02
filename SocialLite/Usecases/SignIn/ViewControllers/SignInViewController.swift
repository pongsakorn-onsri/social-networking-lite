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

extension SignInViewController: UseStoryboard {
    static var storyboardName: String { "SignIn" }
}

final class SignInViewController: BaseViewController<SignInViewModel> {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInWithGoogle: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignInProviders()
        configureBinding()
    }
    
    func configureBinding() {
        registerButton.rx.tap
            .subscribe(onNext: { [weak self]_ in
                self?.viewModel?.router.trigger(.register)
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
}

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        viewModel?.signIn(with: credential)
    }
}
