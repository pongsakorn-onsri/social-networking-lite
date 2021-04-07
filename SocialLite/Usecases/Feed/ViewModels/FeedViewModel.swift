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
        let refresh: Observable<Void>
        let loadMore: Observable<Void>
    }
    
    struct Output {
        let user: Driver<User?>
        let tableData: Driver<[SectionModel]>
        let isFetching: Driver<Bool>
    }
    
    var service: FeedUseCaseProtocol = { FeedUseCaseService() }()
    var refreshAction: PublishSubject<Void> = PublishSubject()
    let deletePostAction: PublishSubject<Post> = PublishSubject()
    let createdPost: PublishSubject<Post> = PublishSubject()
    private let pageSize = 20
    
    func transform(input: Input) -> Output {
        let allPosts = BehaviorRelay<[Post]>(value: [])
        let activityTracker = ActivityTracker()
        
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
                guard let self = self else { return }
                self.router.trigger(.post(delegate: self.createdPost))
            })
            .disposed(by: disposeBag)
        
        input.signOutTapped
            .subscribe(onNext: {
                self.router.trigger(.signout)
            })
            .disposed(by: disposeBag)
        
        createdPost
            .observeOn(MainScheduler.asyncInstance)
            .withLatestFrom(allPosts) { (post, posts) -> [Post] in
                [post] + posts
            }
            .bind(to: allPosts)
            .disposed(by: disposeBag)
        
        deletePostAction
            .flatMap { post in
                self.service.delete(post: post)
                    .trackActivity(activityTracker)
                    .withLatestFrom(allPosts)
                    .map { posts in
                        posts.filter { $0.documentId != post.documentId }
                    }
                    .do(onError: { [weak self]error in
                        self?.router.trigger(.alert(error))
                    })
                    .catchErrorJustReturn(allPosts.value)
            }
            .bind(to: allPosts)
            .disposed(by: disposeBag)
        
        Observable.merge(input.refresh, refreshAction)
            .withLatestFrom(allPosts)
            .flatMap { posts -> Single<[Post]> in
                let firstPost = posts.compactMap { $0.document }.first
                return self.service.fetch(type: .new, document: firstPost)
                    .trackActivity(activityTracker)
                    .map { (newPosts) in
                        var posts = posts
                        posts.insert(contentsOf: newPosts, at: 0)
                        return posts
                    }
                    .asSingle()
            }
            .bind(to: allPosts)
            .disposed(by: disposeBag)
        
        input.loadMore
            .withLatestFrom(allPosts)
            .flatMap { posts -> Single<[Post]> in
                let lastPost = posts.compactMap { $0.document }.last
                return self.service.fetch(type: .old, document: lastPost)
                    .trackActivity(activityTracker)
                    .map { (oldPosts) in
                        var posts = posts
                        posts.append(contentsOf: oldPosts)
                        return posts
                    }
                    .asSingle()
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
            tableData: tableData,
            isFetching: activityTracker
                .debounce(.seconds(1))
                .asDriver()
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
