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
  
  private let actions: HomeStage.Actions
  private let network: P_NetworkInteractor
  private let state: State
  
  init(actions: HomeStage.Actions,
       state: State,
       network: P_NetworkInteractor) {
    
    self.actions = actions
    self.network = network
    self.state = state
    super.init()
    
    observeState()
    observeActions()
    getGists(showLoading: true)
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
    observeRefresh(signal: actions.refresh.asObservable(), showLoading: false)
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
  
  func observeRefresh(signal: Observable<Void>, showLoading: Bool) {
    signal.subscribe(onNext: { [unowned self] in
        print("refresh")
        self.getGists(showLoading: showLoading)
    })
    .addDisposableTo(bag)
  }
  
  private func getGists(showLoading: Bool) {
    let options = showLoading ? [] : [RequestOption.noTrack]
    network.loadGists(options: options).subscribe { [weak self] event in
      if event.error != nil { print("getGists error") }
      if event.isStopEvent {
        self?.endRefreshing.onNext(())
      }
    }
    .addDisposableTo(bag)
  }
}
