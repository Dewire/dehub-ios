//
//  ViewGistDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class ViewGistDirector : BaseDirector<ViewGistScene, ViewGistStage> {
  
  let gist: GistEntity
  let networkInteractor: P_NetworkInteractor

  init(scene: ViewGistScene, networkInteractor: P_NetworkInteractor, gist: GistEntity) {
    self.gist = gist
    self.networkInteractor = networkInteractor
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: ViewGistStage) {
    stage.title = gist.file.filename
    fetchGistText(url: gist.file.raw_url)
  }
  
  private func fetchGistText(url: String) {
    networkInteractor.get(url: url, options: []).map { data in
      String(data: data, encoding: .utf8)!
    }
    .asDriver(onErrorJustReturn: "")
    .drive(onNext: { [weak self] in
      self?.stage.setText(text: $0)
    })
    .addDisposableTo(bag)
  }
}
