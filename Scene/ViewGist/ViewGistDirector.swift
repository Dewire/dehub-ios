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
import Siesta

class ViewGistDirector : BaseDirector<ViewGistScene, ViewGistStage> {
  
  let gist: GistEntity
  let api: GistApi
  let resource: Resource

  init(scene: ViewGistScene, api: GistApi, gist: GistEntity) {
    self.gist = gist
    self.api = api
    resource = api.resource(absoluteURL: gist.file.raw_url)
    
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: ViewGistStage) {
    stage.overlayResources = [resource]
    
    stage.title = gist.file.filename
    
    resource.addObserver(owner: self) { [weak self] resource, event in
      self?.stage.setText(text: resource.typedContent(ifNone: ""))
    }
    
    self.resource.load()
  }
}
