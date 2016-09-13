//
//  CreateGistScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

class CreateGistScene : BaseScene {
  
  override func createStage() -> UIViewController {
    return CreateGistStage.create { stage in
      let d = CreateGistDirector.init(actions: stage.actions, networkInteractor: self.services.networkInteractor)
      self.observeDirector(d)
      return d
    }
  }
  
  fileprivate func observeDirector(_ director: CreateGistDirector) {
  }
}
