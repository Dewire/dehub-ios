//
//  BaseScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model
import RxSwift

open class BaseScene {
  
  let bag = DisposeBag()
  
  weak var navigation: Navigation!
  
  let services: Services
    
  public init(services: Services) {
  	self.services = services
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
  
  open func stage() -> UIViewController {
    let stage = createStage()
    navigation = stage
    return stage
  }
  
  func createStage() -> UIViewController {
    fatalError("must be overriden by subclass")
  }
}

protocol Navigation : class {
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
  func dismiss(animated flag: Bool, completion: (() -> Void)?)
  func pushController(_ viewController: UIViewController, animated: Bool)
  func popController(animated: Bool)
}

extension UIViewController : Navigation {
  
  func pushController(_ viewController: UIViewController, animated: Bool) {
    if let nav = navigationController {
      nav.pushViewController(viewController, animated: animated)
    } else {
      fatalError("tried to push a view controller on a controller that does not have a navigation controller")
    }
  }
  
  func popController(animated: Bool) {
    if let nav = navigationController {
      nav.popViewController(animated: animated)
    } else {
      fatalError("tried to pop a view controller on a controller that does not have a navigation controller")
    }
  }
}
