//
//  FeedViewModel.swift
//  SocialLite
//
//  Created by Pongsakorn Onsri on 2/4/2564 BE.
//

import Foundation
import XCoordinator
import RxSwift
import RxCocoa
import RxDataSources

class FeedViewModel: BaseViewModel {
    
    struct Input {
        let createPostTapped: Observable<Void>
        let signOutTapped: Observable<Void>
        let userChanged: Observable<User?>
    }
    
    struct Output {
        let user: Driver<User?>
        let tableData: Driver<[SectionModel]>
    }
    
    var service: FeedUseCaseProtocol = { FeedUseCaseService() }()
    var refreshAction: PublishSubject<Void> = PublishSubject()
    var loadMoreAction: PublishSubject<Void> = PublishSubject()
    var willDeletePostAction: PublishSubject<Post> = PublishSubject()
    var confirmDeletePost: PublishSubject<Post> = PublishSubject()
    private let pageSize = 20
    
    func transform(input: Input) -> Output {
        let allPosts = BehaviorRelay<[Post]>(value: [])
        
        input.userChanged
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self]user in
                if user == nil {
                    self?.router.trigger(.authenticate)
                } else {
                    self?.refreshAction.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        input.createPostTapped
            .subscribe(onNext: { [weak self]_ in
                self?.router.trigger(.post)
            })
            .disposed(by: disposeBag)
        
        input.signOutTapped
            .subscribe(onNext: {
                self.router.trigger(.signout)
            })
            .disposed(by: disposeBag)
        
        willDeletePostAction
            .subscribe(onNext: { post in
                self.router.trigger(.delete(post, self.confirmDeletePost))
            })
            .disposed(by: disposeBag)
        
        confirmDeletePost
            .flatMap { post in
                self.service.delete(post: post)
                    .map { _ in post }
            }
            .subscribe(onNext: { _ in
                self.refreshAction.onNext(())
            }, onError: { error in
                self.router.trigger(.alert(error))
            })
            .disposed(by: disposeBag)
        
        refreshAction
            .withLatestFrom(allPosts)
            .flatMap { posts -> Single<[Post]> in
                self.service.fetch(type: .new, document: posts.first?.document)
                    .map { (newPosts) in
                        var posts = posts
                        posts.insert(contentsOf: newPosts, at: 0)
                        return posts
                    }
            }
            .bind(to: allPosts)
            .disposed(by: disposeBag)
        
        loadMoreAction
            .withLatestFrom(allPosts)
            .flatMap { posts -> Single<[Post]> in
                self.service.fetch(type: .old, document: posts.last?.document)
                    .map { (oldPosts) in
                        var posts = posts
                        posts.append(contentsOf: oldPosts)
                        return posts
                    }
            }
            .bind(to: allPosts)
            .disposed(by: disposeBag)
        
        
        let sectionItems = allPosts.map { (posts) -> [SectionItem] in
            posts.map { post in
                let viewModel = PostCellViewModel(post: post)
                return SectionItem.post(viewModel: viewModel)
            }
        }
        
        let tableData = sectionItems
            .map { [SectionModel(items: $0)] }
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            user: input.userChanged
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: nil),
            tableData: tableData
        )
    }
}

/// from RxDatasource
extension FeedViewModel {
    struct SectionModel {
        var items: [SectionItem]
    }

    enum SectionItem {
        case post(viewModel: PostCellViewModel)
    }
}

extension FeedViewModel.SectionModel: SectionModelType {
    typealias Item = FeedViewModel.SectionItem

    init(original: FeedViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
