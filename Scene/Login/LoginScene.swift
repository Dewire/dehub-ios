//
//  LoginScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

public class LoginScene : BaseScene {
  
  public override func createStage() -> UIViewController {
    return LoginStage.create { stage in
      let d = LoginDirector.init(actions: stage.actions, networkInteractor: self.services.networkInteractor)
      self.observeDirector(d)
      return d
    }
  }
  
  private func observeDirector(director: LoginDirector) {
    
    director.loginSuccessful.subscribeNext { success in
      self.segueToHomeScene()
      
    }
    .addDisposableTo(director.bag)
  }
  
  func segueToHomeScene() {
    print("segueToHomeScene")
    let presentation = ModalContext(presenter: stageRef!, animated: true)
    let homeScene = HomeScene(presentation: presentation, services: services)
    homeScene.presentInContext()
  }
}