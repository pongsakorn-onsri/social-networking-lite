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
        let signOutTapped: Driver<Void>
        let refreshTrigger: Driver<Void>
        let loadMoreTrigger: Driver<Void>
        let createdPostTrigger: Driver<Void>
        let deletePostTrigger: Driver<Post>
    }
    
    struct Output {
        let tableData = BehaviorRelay<[SectionModel]>(value: [])
        let isRefreshing: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let isLoadingMore: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    }
    
    var useCase: FeedUseCaseType = { FeedUseCaseService() }()
    let deletePostAction: PublishSubject<Post> = PublishSubject()
    let createdPost: PublishSubject<Post> = PublishSubject()
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let refreshingTracker = ActivityTracker()
        let loadingMoreTracker = ActivityTracker()
        
        // Loading
        refreshingTracker
            .asDriver()
            .drive(output.isRefreshing)
            .disposed(by: disposeBag)
        
        loadingMoreTracker
            .asDriver()
            .drive(output.isLoadingMore)
            .disposed(by: disposeBag)
        
        // Get
        let postSubject = BehaviorRelay<[Post]>(value: [])
        let userSubject = BehaviorRelay<User?>(value: nil)
        
        let getPostResult = useCase
            .fetch(type: .new, document: nil)
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { posts in
                postSubject.accept(posts)
            })
        
        let postList = Driver.merge(getPostResult, postSubject.asDriver())
        
        let userChangedTrigger = PublishSubject<User>()
        
        useCase.getUser()
            .mapToOptional()
            .asDriver(onErrorJustReturn: nil)
            .drive(userSubject)
            .disposed(by: disposeBag)
            
        userSubject
            .filter { $0 == nil }
            .flatMapLatest { _ in
                self.router.triggerToSignIn()
            }
            .asDriverOnErrorJustComplete()
            .drive(userChangedTrigger)
            .disposed(by: disposeBag)
        
        input.signOutTapped
            .flatMapLatest {
                self.router.confirmSignOut()
            }
            .flatMapLatest {
                self.useCase.signOut()
                    .asDriverOnErrorJustComplete()
            }
            .map { _ in nil }
            .drive(userSubject)
            .disposed(by: disposeBag)
        
        input.createdPostTrigger
            .withLatestFrom(userSubject.asDriver())
            .compactMap { $0 }
            .flatMapLatest { user in
                self.router.triggerToCreatePost(user: user)
            }
            .drive(onNext: { post in
                let posts = postSubject.value
                postSubject.accept([post] + posts)
            })
            .disposed(by: disposeBag)
        
        input.deletePostTrigger
            .flatMapLatest { (post) in
                self.router.confirmDeletePost(post: post)
            }
            .flatMapLatest { post in
                self.useCase.delete(post: post)
                    .trackActivity(refreshingTracker)
                    .map { _ in post }
                    .asDriver(onErrorJustReturn: post)
            }
            .drive(onNext: { post in
                var posts = postSubject.value
                posts.removeAll(where: { $0 == post })
                postSubject.accept(posts)
            })
            .disposed(by: disposeBag)
        
        Driver.merge(
            input.refreshTrigger,
            userChangedTrigger.mapToVoid().asDriver(onErrorJustReturn: ())
        )
        .flatMapLatest { posts -> Driver<[Post]> in
            let firstPost = postSubject.value.compactMap { $0.document }.first
            return self.useCase.fetch(type: .new, document: firstPost)
                .trackActivity(refreshingTracker)
                .asDriver(onErrorJustReturn: [])
        }
        .drive(onNext: { newPosts in
            let posts = newPosts + postSubject.value
            let postsWithoutDuplicates = posts.withoutDuplicates()
            postSubject.accept(postsWithoutDuplicates)
        })
        .disposed(by: disposeBag)
        
        input.loadMoreTrigger
            .flatMapLatest { posts -> Driver<[Post]> in
                let lastPost = postSubject.value.compactMap { $0.document }.last
                return self.useCase.fetch(type: .old, document: lastPost)
                    .trackActivity(loadingMoreTracker)
                    .asDriver(onErrorJustReturn: [])
            }
            .drive(onNext: { oldPosts in
                let posts = postSubject.value + oldPosts
                let postsWithoutDuplicates = posts.withoutDuplicates()
                postSubject.accept(postsWithoutDuplicates)
            })
            .disposed(by: disposeBag)
        
        let sectionItems = postList.map { (posts) -> [SectionItem] in
            posts.map { post in
                let viewModel = PostCellViewModel(post: post)
                return SectionItem.post(viewModel: viewModel)
            }
        }
        
        sectionItems
            .map { [SectionModel(items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(output.tableData)
            .disposed(by: disposeBag)
        
        return output
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
