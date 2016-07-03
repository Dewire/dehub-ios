//
//  HomeScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 21/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit

class HomeScene : BaseScene {
  
  override func createStage() -> UIViewController {
    return HomeStage.create { stage in
      let d = HomeDirector(actions: stage.actions, state: self.services.state, network: self.services.networkInteractor)
      return d
    }
  }
}
