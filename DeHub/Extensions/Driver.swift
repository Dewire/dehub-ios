//
// Created by Kalle Lindström on 2017-05-31.
// Copyright (c) 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension SharedSequence where S == DriverSharingStrategy {

  func withProgress() -> Driver<Progress<E>> {

    return Driver.concat(
      [Driver.just(Progress.inProgress),
       map { value in
         Progress.completed(value)
       }]
    )
  }

  func triggeredProgress<T>(
    fromSource source: Driver<T>,
    transform: @escaping (T) -> Observable<Bool>
  ) -> Driver<Progress<Bool>> {

    return self
      .withLatestFrom(source) { $1 }
      .flatMap { sourceObject in
        transform(sourceObject)
          .asDriver(onErrorJustReturn: false)
          .withProgress()
      }
      .startWith(Progress.notStarted)
  }
}

extension SharedSequence where S == DriverSharingStrategy {

  func toVoid() -> Driver<Void> {
    return map { _ in () }
  }
}
