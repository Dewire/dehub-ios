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
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let win = createWindow()
    win.makeKeyAndVisible()
    
    let scene = LoginScene(services: Services())
    win.rootViewController = scene.stage()
    
    window = win
    return true
  }
  
  private func createWindow() -> UIWindow {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    return window
  }
}

