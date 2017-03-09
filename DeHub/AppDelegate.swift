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
  var state: State!
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
   
    #if arch(i386) || arch(x86_64)
      logDocumentsPath()
    #endif
    
    let win = createWindow()
    win.makeKeyAndVisible()
    
    let services = Services()
    state = services.state
    state.restoreFromDisk()
    
    let scene = LoginScene(services: services)
    win.rootViewController = scene.stage()
    
    window = win
    return true
  }
  
  private func createWindow() -> UIWindow {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = UIColor.white
    return window
  }
  
  private func logDocumentsPath() {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    print("Documents path: \(documentsPath)")
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    state.persistToDisk()
  }
}
