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
  
  private let actions: HomeStage.Actions
  private let network: P_NetworkInteractor
  private let state: State
  
  init(actions: HomeStage.Actions, state: State, network: P_NetworkInteractor) {
    
    self.actions = actions
    self.network = network
    self.state = state
    super.init()
    
    observeState()
    observeAddButtonTap()
    getGists()
  }
  
  private func observeState() {
    state.gists.asDriver().driveNext { gists in
      print(gists)
    }
    .addDisposableTo(bag)
  }
  
  private func observeAddButtonTap() {
    actions.addButtonTap.bindTo(newGist).addDisposableTo(bag)
  }
  
  private func getGists() {
    network.loadGists().subscribeError { _ in
      print("getUser error")
    }
    .addDisposableTo(bag)
  }
}