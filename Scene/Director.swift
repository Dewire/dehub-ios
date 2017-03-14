//
//  Director.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift

protocol DirectorType {
  /**
  Called when the stage appears (viewDidAppear)
  */
  func stageDidAppear()
}

class Director<Z, S: Stage>: DirectorType {

  let bag = DisposeBag()
  
  let scene: Z
  
  private var didSetStage = false
  
  weak var stage: S! {
    didSet {
      guard !didSetStage else { return }
      if let s = stage {
        stageDidLoad(stage: s)
        didSetStage = true
      }
    }
  }
  
  init(scene: Z) {
    self.scene = scene
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
  
  func stageDidLoad(stage: S) { }

  func stageDidAppear() { }
}


// MARK: ErrorDisplayer
extension Director: ErrorDisplayer {
  
  func display(error: Error) {
    stage.display(error: error)
  }
}


// MARK: SpinnerDisplayer
extension Director: SpinnerDisplayer {
  func hideSpinner() {
    stage.hideSpinner()
  }
  
  func showSpinner() {
    stage.showSpinner()
  }
}


// MARK: ObservableType extensions
extension ObservableType {
  
  func error(_ displayer: ErrorDisplayer) -> Observable<Self.E> {
    return self.do(onError: { [weak displayer] error in
      displayer?.display(error: error)
    })
  }
  
  func spin(_ displayer: SpinnerDisplayer) -> Observable<Self.E> {
    return self.do(onNext: { [weak displayer] _ in displayer?.hideSpinner() },
                   onError: { [weak displayer] _ in displayer?.hideSpinner() },
                   onSubscribe: { [weak displayer] in displayer?.showSpinner() })
  }
}



