//
//  FeedViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import UIKit

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    @IBOutlet weak var createPostButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignOutButton()
        configureViewModel()
    }
    
    func configureSignOutButton() {
        let logoutItem = UIBarButtonItem(title: "Sign out",
                                         style: .plain,
                                         target: self,
                                         action: #selector(signOut))
        navigationItem.setRightBarButton(logoutItem, animated: true)
    }
    
    @objc func signOut() {
        viewModel?.router.trigger(.signout)
    }
    
    func configureViewModel() {
        guard let viewModel = viewModel else { return }
        let input = FeedViewModel.Input(
            createPostTapped: createPostButton.rx.tap.asObservable(),
            userChanged: UserManager.shared.userObservable.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.user
            .compactMap { $0 }
            .drive(onNext: { user in
                self.title = user.displayName
            })
            .disposed(by: disposeBag)
    }
    
}

extension FeedViewController: UseStoryboard {
    static var storyboardName: String { "Feed" }
}
