//
//  HomeDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 21/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Model

class HomeDirector : BaseDirector {
  
  // Scene outputs
  let newGist = PublishSubject<Void>()
  
  fileprivate let actions: HomeStage.Actions
  fileprivate let network: P_NetworkInteractor
  fileprivate let state: State
  
  init(actions: HomeStage.Actions, state: State, network: P_NetworkInteractor) {
    
    self.actions = actions
    self.network = network
    self.state = state
    super.init()
    
    observeState()
    observeAddButtonTap()
    getGists()
  }
  
  fileprivate func observeState() {
    state.gists.asDriver().drive(onNext: { gists in
      print(gists)
    })
    .addDisposableTo(bag)
  }
  
  fileprivate func observeAddButtonTap() {
    actions.addButtonTap.bindTo(newGist).addDisposableTo(bag)
  }
  
  fileprivate func getGists() {
    network.loadGists().subscribe(onError: { _ in
      print("getUser error")
    })
    .addDisposableTo(bag)
  }
}
