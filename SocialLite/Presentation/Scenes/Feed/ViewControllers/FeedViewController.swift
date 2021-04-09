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
import RxCocoa
import RxSwift
import RxDataSources
import ESPullToRefresh

final class FeedViewController: BaseViewController<FeedViewModel> {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var createPostButton: UIBarButtonItem!
    var signOutButton: UIBarButtonItem!
    var refreshControl = UIRefreshControl()
    let appBarViewController = MDCAppBarViewController()
    private var loadMoreTrigger = PublishSubject<Void>()
    private var deletePostTrigger = PublishSubject<Post>()
    private var refreshPostTrigger = PublishSubject<Void>()
    
    var isRefreshing: Binder<Bool> {
        return Binder(refreshControl) { refreshControl, loading in
            if loading {
                refreshControl.beginRefreshing()
            } else {
                if refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    var isLoadingMore: Binder<Bool> {
        return Binder(tableView) { tableView, loading in
            if loading {
                tableView.es.base.footer?.startRefreshing()
            } else {
                tableView.es.stopLoadingMore()
            }
        }
    }
    
    // MARK: - Life Cycle
    
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
        
        let refreshTrigger = Driver.merge(
            refreshPostTrigger.asDriver(onErrorJustReturn: ()),
            refreshControl.rx.controlEvent(.valueChanged).asDriver()
        )
        
        let input = FeedViewModel.Input(
            signOutTapped: signOutButton.rx.tap.asDriver(),
            refreshTrigger: refreshTrigger,
            loadMoreTrigger: loadMoreTrigger.asDriver(onErrorJustReturn: ()),
            createdPostTrigger: createPostButton.rx.tap.asDriver(),
            deletePostTrigger: deletePostTrigger.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        let itemsDataSource = dataSource()
        output.tableData
            .asDriver()
            .drive(tableView.rx.items(dataSource: itemsDataSource))
            .disposed(by: disposeBag)
        
        output.isRefreshing
            .asDriver()
            .drive(isRefreshing)
            .disposed(by: disposeBag)
        
        output.isLoadingMore
            .asDriver()
            .drive(isLoadingMore)
            .disposed(by: disposeBag)
    }
    
    override func applyTheme(with containerScheme: MDCContainerScheming) {
        appBarViewController.applyPrimaryTheme(withScheme: containerScheme)
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
                    self?.refreshPostTrigger.onNext(())
                }
        }
        
        tableView.es.addInfiniteScrolling { [weak self] in
            self?.loadMoreTrigger.onNext(())
        }
    }
    
    func dataSource() -> RxTableViewSectionedReloadDataSource<FeedViewModel.SectionModel> {
        return .init(configureCell: { [weak self]source, tableView, indexPath, _ in
            switch source[indexPath] {
            case let .post(cellViewModel):
                let identifier = String(describing: PostTableViewCell.self)
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                if let postCell = cell as? PostTableViewCell, let self = self {
                    postCell.configure(with: cellViewModel)
                    postCell.deleteButton.rx.tap
                        .map { cellViewModel.post }
                        .bind(to: self.deletePostTrigger)
                        .disposed(by: postCell.disposeBag)
                }
                return cell
            }
        })
    }
}
