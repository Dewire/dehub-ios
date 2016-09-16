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
  let viewGist = PublishSubject<GistEntity>()
  
  // Stage outputs
  let gists = Variable<[GistEntity]>([])
  let endRefreshing = PublishSubject<Void>()
  let showLoadingIndicator = Variable<Bool>(true)
  
  private let actions: HomeStage.Actions
  private let network: P_NetworkInteractor
  private let state: State
  
  init(actions: HomeStage.Actions, state: State, network: P_NetworkInteractor) {
    
    self.actions = actions
    self.network = network
    self.state = state
    super.init()
    
    observeState()
    observeActions()
    getGists()
  }
  
  private func observeState() {
    
    state.gistsObservable
      .filter { $0 != nil }.map { $0! }
      .bindTo(gists).addDisposableTo(bag)
  }
  
  private func observeActions() {
    observeLogoutButtonTap()
    observeAddButtonTap()
    observeRowTap()
    observeRefresh()
  }
  
  private func observeLogoutButtonTap() {
    actions.logoutButtonTap.subscribe(onNext: {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Logout"), object: nil)
    })
    .addDisposableTo(bag)
  }
  
  private func observeAddButtonTap() {
    actions.addButtonTap.bindTo(newGist).addDisposableTo(bag)
  }
  
  private func observeRowTap() {
    actions.rowTap.bindTo(viewGist).addDisposableTo(bag)
  }
  
  private func observeRefresh() {
    actions.refresh.subscribe(onNext: { [unowned self] _ in
      print("refresh")
      self.getGists()
    })
    .addDisposableTo(bag)
  }
  
  private func getGists() {
    network.loadGists().subscribe { [weak self] event in
      if event.error != nil { print("getGists error") }
      if event.isStopEvent {
        self?.endRefreshing.onNext(())
      }
      self?.showLoadingIndicator.value = false
    }
    .addDisposableTo(bag)
  }
}
