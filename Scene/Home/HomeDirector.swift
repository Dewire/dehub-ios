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

class HomeDirector : BaseDirector<HomeScene, HomeStage> {
  
  typealias O = HomeStage.Outputs
  
  fileprivate let network: P_NetworkInteractor
  fileprivate let state: State
  
  init(scene: HomeScene,
       state: State,
       network: P_NetworkInteractor) {
    
    self.network = network
    self.state = state
    super.init(scene: scene)
    
    getGists(showLoading: true)
  }
  
  override func stageDidLoad(stage: HomeStage) {
    observe(outputs: stage.outputs)
    gistSectionDriver().drive(
      stage.inputs.tableView.items(dataSource: stage.inputs.tableViewDataSource))
      .addDisposableTo(bag)
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
      .filter { $0 != nil }.map { $0! }
      .subscribe(onNext: { [unowned self] gist in
        self.scene.onViewGist(gist: gist)
      })
      .addDisposableTo(bag)
  }
  
  func observeRefresh(_ outputs: O) {
    outputs.refresh.asObservable().subscribe(onNext: { [unowned self] in
      print("refresh")
      self.getGists(showLoading: false)
    })
    .addDisposableTo(bag)
  }
  
  func getGists(showLoading: Bool) {
    let options = showLoading ? [] : [RequestOption.noTrack]
    network.loadGists(options: options).subscribe { [weak self] event in
      if event.error != nil { print("getGists error") }
      if event.isStopEvent {
        self?.stage.stopRefreshing()
      }
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

extension HomeDirector {
  
  func gistSectionDriver() -> Driver<[GistSection]> {
    
    return state.gistsDriver.map { gists in
      guard let gists = gists else { return [] }
      
      let groups = gists.groupBy { $0.isPublic }
      
      let publicGists = GistSection(header: "Public Gists", items: groups.match)
      let privateGists = GistSection(header: "Private Gists", items: groups.noMatch)
      
      return [publicGists, privateGists]
    }
  }
}











