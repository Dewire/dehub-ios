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
    
    let s = LoginStage.create()
    s.afterLoad = {
      let d = LoginDirector(scene: self, api: self.services.api)
      s.directorRef = d
      d.stage = s
    }
    
    return s
  }
  
  func login() {
    let homeStage = HomeScene(services: services).stage()
    let navController = UINavigationController(rootViewController: homeStage)
    navigation.present(navController, animated: true, completion: nil)
  }
  
  func logout() {
    navigation.dismiss(animated: true, completion: nil)
    services.api.logout()
  }
  
}
