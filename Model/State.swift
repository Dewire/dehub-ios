//
//  State.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift

open class State {
  
  open var gists: Variable<[GistEntity]?> = Variable(nil)
  
}
