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
  
  private let gist: GistEntity
  
  public init(services: Services, gist: GistEntity) {
    self.gist = gist
    super.init(services: services)
  }
  
  override func createStage() -> UIViewController {
    
    let s = ViewGistStage.create()
    s.afterLoad = {
      let d = ViewGistDirector(scene: self,
                               api: self.services.api,
                               gist: self.gist)
      s.directorRef = d
      d.stage = s
    }
    
    return s
  }
}
