//
//  HomeScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 21/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model
import RxSwift

class HomeScene : BaseScene {
  
  var newGistCallback: Closure!
  
  override func createStage() -> UIViewController {
    
    let s = HomeStage.create()
    s.afterLoad = {
      let d = HomeDirector(scene: self,
                           api: self.services.api)
      s.directorRef = d
      d.stage = s
      
      self.newGistCallback = { [weak d] in d?.loadGists() }
    }
    
    return s
  }
  
  func onNewGist() {
    print("new gist")
    let scene = CreateGistScene(services: self.services, newGistCallback: newGistCallback)
    self.navigation.pushController(scene.stage(), animated: true)
  }
  
  func onViewGist(gist: GistEntity) {
    let stage = ViewGistScene(services: self.services, gist: gist).stage()
    self.navigation.pushController(stage, animated: true)
  }
  
}
