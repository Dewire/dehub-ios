//
//  HomeScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 21/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

class HomeScene : BaseScene {
  
  override func createStage() -> UIViewController {
    return HomeStage.create { stage in
      let d = HomeDirector(actions: stage.actions, state: self.services.state, network: self.services.networkInteractor)
      self.observeDirector(d)
      return d
    }
  }
  
  private func observeDirector(director: HomeDirector) {
    director.newGist.subscribeNext() {
      let createGistStage = CreateGistScene(services: self.services).stage()
      self.stageRef.navigationController?.pushViewController(createGistStage, animated: true)
    }
    .addDisposableTo(bag)
  }
}
