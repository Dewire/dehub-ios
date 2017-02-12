//
//  State.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-01-23.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift

public final class State {
  let _gists = Variable<[GistEntity]>([])
  public let gists: Observable<[GistEntity]>
  
  init() {
    gists = _gists.asObservable()
  }
}
