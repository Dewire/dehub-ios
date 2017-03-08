//
//  CreateGistScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model
import RxSwift

class CreateGistScene: BaseScene {
  
  let newGistCallback: Closure
  
  init(services: Services, newGistCallback: @escaping Closure) {
    self.newGistCallback = newGistCallback
    super.init(services: services)
  }
  
  override func createStage() -> UIViewController {
    let s = CreateGistStage.create()
    s.afterLoad = {
      let d = CreateGistDirector(scene: self,
                               api: self.services.api)
      s.directorRef = d
      d.stage = s
    }
    
    return s
  }
  
  func gistCreated() {
    newGistCallback()
    self.navigation.popController(animated: true)
  }
}
