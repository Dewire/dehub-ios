//
//  LoginScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

open class LoginScene : BaseScene {
  
  open override func createStage() -> UIViewController {
    return LoginStage.create { stage in
      let d = LoginDirector.init(actions: stage.actions, networkInteractor: self.services.networkInteractor)
      self.observeDirector(d)
      return d
    }
  }
  
  func observeDirector(_ director: LoginDirector) {
    observeLoginSuccessful(director)
    observeLogoutRequested(director)
  }
  
  private func observeLoginSuccessful(_ director: LoginDirector) {
    director.loginSuccessful.subscribe(onNext: {
      self.segueToHomeScene()
    })
    .addDisposableTo(director.bag)
  }
  
  private func segueToHomeScene() {
    print("segueToHomeScene")
    let homeStage = HomeScene(services: services).stage()
    let navController = UINavigationController(rootViewController: homeStage)
    navigation.present(navController, animated: true, completion: nil)
  }
  
  private func observeLogoutRequested(_ director: LoginDirector) {
    director.logoutRequested.bindNext { _ in
      self.navigation.dismiss(animated: true, completion: nil)
      self.services.state.reset()
    }
    .addDisposableTo(bag)
  }
}
