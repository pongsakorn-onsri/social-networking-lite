//
//  FeedViewController.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import UIKit
import EmptyDataSet_Swift
import RxDataSources
import MaterialComponents

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    var createPostButton: UIBarButtonItem!
    var signOutButton: UIBarButtonItem!
    var refreshControl = UIRefreshControl()
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
        
        let refresh = refreshControl.rx.controlEvent(.valueChanged)
        let loadMore = tableView.rx.prefetchRows.map { _ in () }
        
        let input = FeedViewModel.Input(
            createPostTapped: createPostButton.rx.tap.asObservable(),
            signOutTapped: signOutButton.rx.tap.asObservable(),
            userChanged: UserManager.shared.userObservable.asObservable(),
            refresh: refresh.asObservable(),
            loadMore: loadMore.asObservable()
        )
        let output = viewModel.transform(input: input)
        output.user
            .compactMap { $0 }
            .drive(onNext: { user in
                self.title = user.displayName
            })
            .disposed(by: disposeBag)
        
        let itemsDataSource = dataSource()
        output.tableData
            .drive(tableView.rx.items(dataSource: itemsDataSource))
            .disposed(by: disposeBag)
        
        output.isFetching
            .drive(refreshControl.rx.isRefreshing)
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
        let identifier = String(describing: PostTableViewCell.self)
        let postCellNib = UINib(nibName: identifier, bundle: Bundle.main)
        tableView.register(postCellNib, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
        
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
    
    func dataSource() -> RxTableViewSectionedReloadDataSource<FeedViewModel.SectionModel> {
        return .init(configureCell: { source, tableView, indexPath, _ in
            switch source[indexPath] {
            case let .post(cellViewModel):
                let identifier = String(describing: PostTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                let postCell = cell as? PostTableViewCell
                postCell?.configure(with: cellViewModel)
                postCell?.deleteButton.rx.tap
                    .subscribe(onNext: { [weak self]_ in
                        guard let viewModel = self?.viewModel else { return }
                        viewModel.router.trigger(.deleteAlert(post: cellViewModel.post,      
                                                              delegate: viewModel.deletePostAction))
                    })
                    .disposed(by: self.disposeBag)
                return cell
            }
        })
    }
}
