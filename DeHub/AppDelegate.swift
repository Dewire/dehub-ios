//
//  AppDelegate.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Scene
import Model

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let win = createWindow()
    win.makeKeyAndVisible()
    
    let scene = LoginScene(services: Services())
    win.rootViewController = scene.stage()
    
    window = win
    return true
  }
  
  private func createWindow() -> UIWindow {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = UIColor.white
    return window
  }
}
