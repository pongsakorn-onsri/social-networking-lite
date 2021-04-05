//
//  TestSchedulerExtensions.swift
//  SocialLiteTests
//
//  Created by Pongsakorn Onsri on 5/4/2564 BE.
//

import RxSwift
import RxTest

extension TestScheduler {
    /// Creates a `TestableObserver` handles subscription and dispose it
    func record<O: ObservableConvertibleType>(_ source: O) -> TestableObserver<O.Element> {
        let observer = createObserver(O.Element.self)
        let disposable = source.asObservable().bind(to: observer)
        scheduleAt(100000) {
            disposable.dispose()
        }
        return observer
    }

    func send<T>(_ event: T, at time: VirtualTime, to target: PublishSubject<T>) {
        scheduleAt(time) {
            target.onNext(event)
        }
    }
}
