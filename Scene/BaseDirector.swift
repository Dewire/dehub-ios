//
//  BaseDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import Siesta

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
  
  func stageDidLoad(stage: Stage) { }
}


extension Resource {
  
  func noOverlayLoad(_ stage: DirectedViewController) -> Request {
    
    let original = stage.overlayResources
    
    stage.overlayResources = original.filter {
      $0 != self
    }
    
    let req = load()
    req.onCompletion { [weak stage] _ in
      stage?.overlayResources = original
    }
    return req
  }
  
  func noOverlayLoadIfNeeded(_ stage: DirectedViewController) -> Request? {
    
    let original = stage.overlayResources
    
    stage.overlayResources = original.filter {
      $0 != self
    }
    
    let req = loadIfNeeded()
    req?.onCompletion { [weak stage] _ in
      stage?.overlayResources = original
    }
    return req
  }
}




