//
//  CreateGistScene.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import Model
import RxSwift

class CreateGistScene : BaseScene {
  
  // HomeScene outputs
  let refreshNeeded = PublishSubject<Void>()
  
  override func createStage() -> UIViewController {
    return CreateGistStage.create { stage in
      let d = CreateGistDirector.init(actions: stage.actions, networkInteractor: self.services.networkInteractor)
      self.observeDirector(d)
      return d
    }
  }
  
  private func observeDirector(_ director: CreateGistDirector) {
    director.gistCreated.asDriver(onErrorJustReturn: ()).drive(onNext: {
      print(self)
      self.refreshNeeded.onNext(())
      self.navigation.popController(animated: true)
    })
    .addDisposableTo(bag)
  }
}
