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
    observeLoginSuccessful(director)
    observeLogoutRequested(director)
  }
  
  private func observeLoginSuccessful(director: LoginDirector) {
    director.loginSuccessful.subscribeNext { _ in
      self.segueToHomeScene()
    }
    .addDisposableTo(director.bag)
  }
  
  private func segueToHomeScene() {
    print("segueToHomeScene")
    let homeStage = HomeScene(services: services).stage()
    let navController = UINavigationController(rootViewController: homeStage)
    stageRef.presentViewController(navController, animated: true, completion: nil)
  }
  
  private func observeLogoutRequested(director: LoginDirector) {
    director.logoutRequested.bindNext { _ in
      self.stageRef.dismissViewControllerAnimated(true, completion: nil)
    }
    .addDisposableTo(bag)
  }
}