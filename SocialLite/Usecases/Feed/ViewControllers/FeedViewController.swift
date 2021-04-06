//
//  FeedViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import UIKit
import EmptyDataSet_Swift
import MaterialComponents

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    var createPostButton: UIBarButtonItem!
    var signOutButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let appBarViewController = MDCAppBarViewController()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addChild(appBarViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureViewModel()
    }
    
    func configureViewModel() {
        guard let viewModel = viewModel else { return }
        let input = FeedViewModel.Input(
            createPostTapped: createPostButton.rx.tap.asObservable(),
            signOutTapped: signOutButton.rx.tap.asObservable(),
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

extension FeedViewController {
    
    func configureViews() {
        navigationItem.title = "Timeline"
        configureSignOutButton()
        configureNavigationBar()
        configureTableView()
    }
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.addSubview(appBarViewController.view)
        appBarViewController.didMove(toParent: self)
        appBarViewController.headerView.minMaxHeightIncludesSafeArea = true
        appBarViewController.headerView.trackingScrollView = tableView
        tableView.delegate = appBarViewController
    }
    
    func configureSignOutButton() {
        createPostButton = UIBarButtonItem(title: "Create post",
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        navigationItem.setLeftBarButton(createPostButton, animated: true)
        
        signOutButton = UIBarButtonItem(title: "Sign out",
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        navigationItem.setRightBarButton(signOutButton, animated: true)
    }
    
    func configureTableView() {
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetView { (customView) in
            customView
                .titleLabelString(.init(string: "No posts 😝"))
                .detailLabelString(.init(string: "Create one or refresh timeline :]"))
                .buttonTitle(.init(string: "Refresh!"), for: .normal)
                .buttonTitle(.init(string: "Refresh!"), for: .highlighted)
                .isScrollAllowed(true)
                .didTapDataButton { [weak self] in
                    self?.viewModel?.refreshAction.onNext(())
                }
            
        }
    }
}
