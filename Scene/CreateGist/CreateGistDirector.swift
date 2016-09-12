//
//  CreateGistDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class CreateGistDirector : BaseDirector {
  
  let networkInteractor: P_NetworkInteractor

  init(actions: CreateGistStage.Actions, networkInteractor: P_NetworkInteractor) {
    self.networkInteractor = networkInteractor
    super.init()

  }

}
