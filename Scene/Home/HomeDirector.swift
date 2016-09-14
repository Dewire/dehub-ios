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
  
  // Stage outputs
  let gists = Variable<[GistEntity]>([])
  
  fileprivate let actions: HomeStage.Actions
  fileprivate let network: P_NetworkInteractor
  fileprivate let state: State
  
  init(actions: HomeStage.Actions, state: State, network: P_NetworkInteractor) {
    
    self.actions = actions
    self.network = network
    self.state = state
    super.init()
    
    observeState()
    observeLogoutButtonTap()
    observeAddButtonTap()
    getGists()
  }
  
  fileprivate func observeState() {
    state.gists.asObservable()
      .filter { $0 != nil }.map { $0! }
      .bindTo(gists).addDisposableTo(bag)
  }
  
  fileprivate func observeLogoutButtonTap() {
    
    actions.logoutButtonTap.subscribe(onNext: {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Logout"), object: nil)
    })
    .addDisposableTo(bag)
  }
  
  fileprivate func observeAddButtonTap() {
    actions.addButtonTap.bindTo(newGist).addDisposableTo(bag)
  }
  
  fileprivate func getGists() {
    network.loadGists().subscribe(onError: { _ in
      print("getGists error")
    })
    .addDisposableTo(bag)
  }
}
