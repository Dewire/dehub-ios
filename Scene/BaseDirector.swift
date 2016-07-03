//
//  BaseDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift

class BaseDirector {
  
  let bag = DisposeBag()
  
  deinit {
    print("🗑 \(self.dynamicType) deinit")
  }
}