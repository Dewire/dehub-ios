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
  let api: GistApi

  init(scene: ViewGistScene, api: GistApi, gist: GistEntity) {
    self.gist = gist
    self.api = api
    
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: ViewGistStage) {
    
    stage.title = gist.file.filename
    
    api.getText(forGist: gist)
      .spin(self).error(self)
      .subscribe(onNext: { [weak self] text in
        self?.stage.setText(text: text)
      })
      .addDisposableTo(bag)
  }
}
