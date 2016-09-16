//
//  ViewGistScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

class ViewGistScene : BaseScene {
  
  let gist: GistEntity
  
  public init(services: Services, gist: GistEntity) {
    self.gist = gist
    super.init(services: services)
  }
  
  override func createStage() -> UIViewController {
    return ViewGistStage.create { stage in
      let d = ViewGistDirector.init(
        actions: stage.actions,
        networkInteractor: self.services.networkInteractor,
        gist: self.gist)
      
      self.observeDirector(d)
      return d
    }
  }
  
  fileprivate func observeDirector(_ director: ViewGistDirector) {
  }
}
