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
import RxDataSources
import Model

class HomeDirector: BaseDirector<HomeScene, HomeStage> {
  
  typealias O = HomeStage.Outputs
  
  fileprivate let api: GistApi
  
  fileprivate let state: State
  
  init(scene: HomeScene,
       api: GistApi,
       state: State) {
    
    self.api = api
    self.state = state
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: HomeStage) {
    
    state.gists.subscribe(onNext: { [unowned self] gists in
      self.stage.inputs.source.value = self.gistsToSections(gists)
    })
    .addDisposableTo(bag)
    
    observe(outputs: stage.outputs)
    loadGists()
  }
  
  func loadGists() {
    api.loadGists().spin(self).error(self).subscribe().addDisposableTo(bag)
  }
  
  private func gistsToSections(_ gists: [GistEntity]) -> [GistSection] {
    let groups = gists.groupBy { $0.isPublic }
    
    let publicGists = GistSection(header: L("Public Gists"), items: groups.match)
    let privateGists = GistSection(header: L("Private Gists"), items: groups.noMatch)
    
    return [publicGists, privateGists]
  }
  
  private func observe(outputs: O) {
    observeLogoutButtonTap(outputs)
    observeAddButtonTap(outputs)
    observeRowTap(outputs)
    observeRefresh(outputs)
  }
  
  private func observeLogoutButtonTap(_ outputs: O) {
    outputs.logoutButtonTap.subscribe(onNext: {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Logout"), object: nil)
    })
    .addDisposableTo(bag)
  }
  
  private func observeAddButtonTap(_ outputs: O) {
    outputs.addButtonTap.subscribe(onNext: { [unowned self] in
      self.scene.onNewGist()
    })
    .addDisposableTo(bag)
  }
  
  private func observeRowTap(_ outputs: O) {
    outputs.rowTap
      .withoutNils()
      .subscribe(onNext: { [unowned self] gist in
        self.scene.onViewGist(gist: gist)
      })
      .addDisposableTo(bag)
  }
  
  func observeRefresh(_ outputs: O) {
    outputs.refresh.asObservable()
      .flatMap { [unowned self] in
        self.api.invalidateNextCache().loadGists()
          .error(self)
          .catchErrorJustReturn(())
      }
      .subscribe { [unowned self] _ in
        self.stage.stopRefreshing()
      }
      .addDisposableTo(bag)
  }
}

struct GistSection: SectionModelType {
  typealias Item = GistEntity
  
  var header: String
  var items: [Item]
}

extension GistSection {
  init(original: GistSection, items: [Item]) {
    self = original
    self.items = items
  }
}
