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
  
  private func observeDirector(_ director: HomeDirector) {
    observeNewGist(director)
    observeViewGist(director)
  }
  
  private func observeNewGist(_ director: HomeDirector) {
    director.newGist.subscribe(onNext: {
      let createGistStage = CreateGistScene(services: self.services).stage()
      self.navigation.pushController(createGistStage, animated: true)
    })
    .addDisposableTo(bag)
  }
  
  private func observeViewGist(_ director: HomeDirector) {
    director.viewGist.subscribe(onNext: { model in
      let stage = ViewGistScene(services: self.services, gist: model).stage()
      self.navigation.pushController(stage, animated: true)
    })
    .addDisposableTo(bag)
  }
  
}
