//
//  ObservableType.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-02-12.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
  
  func toVoid() -> Observable<Void> {
    return map { _ in () }
  }
}
