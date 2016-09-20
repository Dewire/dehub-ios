//
//  File.swift
//  DeHub
//
//  Created by Kalle Lindström on 02/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
  
  public func doOnNextAndError(callback: @escaping () -> ()) -> RxSwift.Observable<Self.E> {
    return self.do(onNext: { _ in callback() }, onError: { _ in callback() })
  }
  
  public func doOnErrorAndCompleted(callback: @escaping () -> ()) -> RxSwift.Observable<Self.E> {
    return self.do(onError: { _ in callback() }, onCompleted: { _ in callback() })
  }
  
}

