//
//  CreateGistDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class CreateGistDirector: Director<CreateGistScene, CreateGistStage> {
  
  private let api: GistApi

  init(scene: CreateGistScene, api: GistApi) {
    self.api = api
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: CreateGistStage) {
    observeOutputs(outputs: stage.outputs)
  }
  
  private func observeOutputs(outputs: CreateGistStage.Outputs) {
    
    let gist = Observable.combineLatest(
      outputs.titleText.withoutNils(),
      outputs.contentText.withoutNils(),
      outputs.privatePublic) { t, c, p -> CreateGistEntity? in
        
      guard !t.isEmpty && !c.isEmpty else { return nil }
        
      return CreateGistEntity(
        description: t,
        isPublic: p == 1,
        file: CreateGistFileInfo(content: c))
    }
    
    observeEnableSaveButton(gist: gist)
    observeSaveGist(saveButtonTapped: outputs.saveButtonTapped, gist: gist)
  }
  
  private func observeEnableSaveButton(gist: Observable<CreateGistEntity?>) {
    gist.map { $0 != nil }
      .subscribe(onNext: { [unowned self] in
        self.stage.enableSaveButton($0)
      })
      .addDisposableTo(bag)
  }
  
  private func observeSaveGist(saveButtonTapped: ControlEvent<Void>, gist: Observable<CreateGistEntity?>) {
    saveButtonTapped
      .withLatestFrom(gist)
      .subscribe(onNext: { [weak self] gist in
        guard let gist = gist else { return }
        self?.createGist(gist: gist)
      })
      .addDisposableTo(bag)
  }
  
  private func createGist(gist: CreateGistEntity) {
    stage.enableSaveButton(false)
    
    api.create(gist: gist)
      .spin(self).error(self)
      .subscribe(
        onNext: { [weak self] _ in
          print("create ok")
          self?.scene.gistCreated()
        },
        onError: { [weak self] err in
          print("create failed: \(err)")
          self?.stage.enableSaveButton(true)
        })
      .addDisposableTo(bag)
  }
}
