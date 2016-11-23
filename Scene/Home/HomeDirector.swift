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
import Siesta

class HomeDirector : BaseDirector<HomeScene, HomeStage> {
  
  typealias O = HomeStage.Outputs
  
  fileprivate let api: GistApi
  
  init(scene: HomeScene,
       api: GistApi) {
    
    self.api = api
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: HomeStage) {
    addApiObservers()
    observe(outputs: stage.outputs)
    stage.overlayResources = [api.gists]
    api.gists.loadIfNeeded()
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
      .unwrap()
      .subscribe(onNext: { [unowned self] gist in
        self.scene.onViewGist(gist: gist)
      })
      .addDisposableTo(bag)
  }
  
  func observeRefresh(_ outputs: O) {
    outputs.refresh.asObservable().subscribe(onNext: { [unowned self] in
      self.loadGists(useStatusOverlay: false)
    })
    .addDisposableTo(bag)
  }
  
  func loadGists(useStatusOverlay: Bool = true) {
    let req = useStatusOverlay ? api.gists.load() : api.gists.noOverlayLoad(stage)
    
    req.onCompletion { [weak self] _ in
      self?.stage.stopRefreshing()
    }
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

extension HomeDirector {
  
  fileprivate func addApiObservers() {
    api.gists.addObserver(owner: self) { [weak self] resource, event in
      guard let s = self else { return }
      
      if let t: [GistEntity] = resource.typedContent() {
        s.stage.inputs.source.value = s.gistsToSections(t)
      }
    }
  }
  
  private func gistsToSections(_ gists: [GistEntity]) -> [GistSection] {
    let groups = gists.groupBy { $0.isPublic }
    
    let publicGists = GistSection(header: "Public Gists", items: groups.match)
    let privateGists = GistSection(header: "Private Gists", items: groups.noMatch)
    
    return [publicGists, privateGists]
  }
}









