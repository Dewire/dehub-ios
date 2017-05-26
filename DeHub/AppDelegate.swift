//
//  AppDelegate.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    #if DEBUG
      if isRunningTest {
        return true
      }
    #endif

    #if arch(i386) || arch(x86_64)
      logDocumentsPath()
    #endif

    Services.shared.state.restoreFromDisk()
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    self.window?.rootViewController = mainStoryboard.instantiateInitialViewController()
    self.window?.makeKeyAndVisible()
    
    return true
  }
  
  private func logDocumentsPath() {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    print("Documents path: \(documentsPath)")
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    Services.shared.state.persistToDisk()
  }
  
  var isRunningTest: Bool {
    return ProcessInfo.processInfo.environment["XCInjectBundleInto"] != nil
  }
}
