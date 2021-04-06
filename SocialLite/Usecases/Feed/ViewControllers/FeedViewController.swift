//
//  FeedViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import UIKit
import MaterialComponents

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    @IBOutlet weak var createPostButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let appBarViewController = MDCAppBarViewController()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addChild(appBarViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Timeline"
        configureSignOutButton()
        configureNavigationBar()
        configureViewModel()
    }
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(appBarViewController.view)
        appBarViewController.didMove(toParent: self)
        appBarViewController.headerView.minMaxHeightIncludesSafeArea = false
        appBarViewController.headerView.trackingScrollView = tableView
        tableView.delegate = appBarViewController
    }
    
    func configureSignOutButton() {
        let logoutItem = UIBarButtonItem(title: "Sign out",
                                         style: .plain,
                                         target: self,
                                         action: #selector(signOut))
        navigationItem.setRightBarButtonItems([logoutItem], animated: true)
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
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applySurfaceTheme(withScheme: containerScheme)
    }
    
}

extension FeedViewController: UseStoryboard {
    static var storyboardName: String { "Feed" }
}
