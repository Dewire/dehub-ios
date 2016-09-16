//
//  State.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class State {
  
  let gists: Variable<[GistEntity]?> = Variable(nil)
  public var gistsDriver: Driver<[GistEntity]?> { return gists.asDriver() }
  public var gistsObservable: Observable<[GistEntity]?> { return gists.asObservable() }
  
  public func reset() {
    gists.value = nil
  }
  
}
