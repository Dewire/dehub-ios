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
    
  	window = createWindow()
    window!.makeKeyAndVisible()
    
    let context = WindowContext.init(window: window!)
    let scene = LoginScene.init(presentation: context, services: Services())
    scene.presentInContext()
    
    return true
  }
  
  private func createWindow() -> UIWindow {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    return window
  }
}

