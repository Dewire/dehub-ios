//
//  BaseScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model

public class BaseScene {
  
  weak var stageRef: UIViewController!
  
  let presentation: Presentation
  let services: Services
  
  public func presentInContext() {
    presentation.present(stage())
  }
  
  public func stage() -> UIViewController {
    stageRef = createStage()
    return stageRef!
  }
  
  public func createStage() -> UIViewController {
    fatalError("must be overriden by subclass")
  }
  
  public init(presentation: Presentation, services: Services) {
    self.presentation = presentation
  	self.services = services
  }
  
  deinit {
    print("🗑 \(self.dynamicType) deinit")
  }
}
