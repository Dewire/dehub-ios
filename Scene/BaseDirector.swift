//
//  BaseDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift

class BaseDirector<Scene, Stage: AnyObject> {
  
  let bag = DisposeBag()
  
  let scene: Scene
  
  private var didSetStage = false
  
  weak var stage: Stage! {
    didSet {
      guard !didSetStage else { return }
      if let s = stage {
        stageDidLoad(stage: s)
        didSetStage = true
      }
    }
  }
  
  init(scene: Scene) {
    self.scene = scene
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
  
  func stageDidLoad(stage: Stage) {
  }
}
