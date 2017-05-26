//
//  HomeViewModel.swift
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

public class HomeViewModel: ViewModel {
  
  fileprivate let api: GistApi
  fileprivate let state: State

  struct Inputs {
    let logoutButtonTap: ControlEvent<Void>
    let addButtonTap: ControlEvent<Void>
    let rowTap: Observable<GistEntity>
    let refresh: ControlEvent<Void>
  }

  struct Outputs {
    let gists: Driver<[GistSection]>
    let navigateNewGist: Driver<Void>
    let navigateViewGist: Driver<GistEntity>
    let stopRefresh: Driver<Void>
  }
  
  init(services: Services) {
    self.api = services.api
    self.state = services.state
  }

  func observe(inputs: Inputs, bag: DisposeBag) -> Outputs {
    api.loadGists().subscribe().disposed(by: bag)

    inputs.logoutButtonTap.subscribe(onNext: {
      NotificationCenter.default.post(name: Notification.Name("Logout"), object: nil)
    })
    .disposed(by: bag)

    let stopRefresh = inputs.refresh.asDriver().flatMap {
      self.api.loadGists(force: true).error().asDriver(onErrorJustReturn: ())
    }

    let sections = state.gists
      .map { self.gistsToSections($0) }
      .spin()
      .asDriver(onErrorJustReturn: [])

    return Outputs(
      gists: sections,
      navigateNewGist: inputs.addButtonTap.asDriver(),
      navigateViewGist: inputs.rowTap.asDriverOrDie(),
      stopRefresh: stopRefresh
    )
  }

  private func gistsToSections(_ gists: [GistEntity]) -> [GistSection] {
    let groups = gists.groupBy { $0.isPublic }

    let publicGists = GistSection(header: L("Public Gists"), items: groups.match)
    let privateGists = GistSection(header: L("Private Gists"), items: groups.noMatch)

    return [publicGists, privateGists]
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
