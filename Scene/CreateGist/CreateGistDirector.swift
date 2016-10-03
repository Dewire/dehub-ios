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

class CreateGistDirector : BaseDirector<CreateGistScene, CreateGistStage> {
  
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
      outputs.titleText,
      outputs.contentText,
      outputs.privatePublic) { t, c, p -> CreateGistEntity? in
        
      guard !t.isEmpty && !c.isEmpty else { return nil }
        
      return CreateGistEntity(
        description: t,
        isPublic: p == 1,
        file: CreateGistFileInfo(content: c))
    }
    .asDriver(onErrorJustReturn: nil)
    
    observeEnableSaveButton(gist: gist)
    observeSaveGist(saveButtonTapped: outputs.saveButtonTapped, gist: gist)
  }
  
  private func observeEnableSaveButton(gist: Driver<CreateGistEntity?>) {
    gist.map { $0 != nil }
      .drive(onNext: { [unowned self] in
        self.stage.enableSaveButton($0)
      })
      .addDisposableTo(bag)
  }
  
  private func observeSaveGist(saveButtonTapped: ControlEvent<Void>, gist: Driver<CreateGistEntity?>) {
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
    
    api.gists.request(.post, json: gist.json())
      .onFailure { [weak self] in
        print("create failed: \($0)")
        self?.stage.enableSaveButton(true)
      }
      .onSuccess { [weak self] _ in
        print("create ok")
        self?.scene.gistCreated()
      }
  }
}
