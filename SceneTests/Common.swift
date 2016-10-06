//
//  Common.swift
//  DeHub
//
//  Created by Kalle Lindström on 15/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
@testable import Model
@testable import Scene
import RxSwift

class SpyNavigation : Navigation {
  
  var presentedController: UIViewController?
  var pushedController: UIViewController?
  var dismissCalled = false
  var poppedController = false
  
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    presentedController = viewControllerToPresent
  }
  
  func dismiss(animated flag: Bool, completion: (() -> Void)?) {
    dismissCalled = true
  }
  
  func pushController(_ viewController: UIViewController, animated: Bool) {
    pushedController = viewController
  }
  
  func popController(animated: Bool) {
    poppedController = true
  }
}

func json(forFile: String) -> Data {
  
  func filePath(_ file: String) -> String {
    return "json/\(file)"
  }
  
  let bundle = Bundle(for: SpyNavigation.self)
  let url = bundle.url(forResource: filePath(forFile), withExtension: nil)!
  
  return try! Data.init(contentsOf: url)
}


class SpyLoginScene : LoginScene {
  var called_createStage: Bool = false
  var called_login: Bool = false
  var called_logout: Bool = false

  override func createStage() -> UIViewController {
    called_createStage = true
    return super.createStage()
  }

  override func login() {
    called_login = true
  }

  override func logout() {
    called_logout = true
  }
}
