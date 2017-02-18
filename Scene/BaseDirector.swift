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
  
  func stageDidLoad(stage: Stage) { }
}


//MARK: ErrorDisplayer
extension BaseDirector: ErrorDisplayer {
  
  func display(error: Error) {
    guard let stage = stage as? ErrorDisplayer else {
      fatalError("Tried to call display:error from a director when the stage did not implement ErrorDisplayer")
    }
    stage.display(error: error)
  }
}


//MARK: SpinnerDisplayer
extension BaseDirector: SpinnerDisplayer {
  func hideSpinner() {
    guard let stage = stage as? SpinnerDisplayer else {
      fatalError("Tried to call hideSpinner from a director when the stage did not implement SpinnerDisplayer")
    }
    stage.hideSpinner()
  }
  
  func showSpinner() {
    guard let stage = stage as? SpinnerDisplayer else {
      fatalError("Tried to call showSpinner from a director when the stage did not implement SpinnerDisplayer")
    }
    stage.showSpinner()
  }
}


//MARK: ObservableType extensions
extension ObservableType {
  
  func error(_ displayer: ErrorDisplayer) -> Observable<Self.E> {
    return self.do(onError: { error in
      displayer.display(error: error)
    })
  }
  
  func spin(_ displayer: SpinnerDisplayer) -> Observable<Self.E> {
    return self.do(onError: { _ in displayer.hideSpinner() },
                   onCompleted: { displayer.hideSpinner() },
                   onSubscribe: { displayer.showSpinner() })
  }
}



