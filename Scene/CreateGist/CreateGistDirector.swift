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
  
  private let networkInteractor: P_NetworkInteractor

  init(scene: CreateGistScene, networkInteractor: P_NetworkInteractor) {
    self.networkInteractor = networkInteractor
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: CreateGistStage) {
    observeOutputs(outputs: stage.outputs)
  }
  
  private func observeOutputs(outputs: CreateGistStage.Outputs) {
    
    let gist = [outputs.titleText, outputs.contentText].combineLatest { texts -> CreateGistEntity? in
      guard !texts.contains("") else { return nil }
      return CreateGistEntity(
        description: texts[0],
        isPublic: false,
        file: CreateGistFileInfo(content: texts[1]))
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
    networkInteractor.create(gist: gist, options: []).subscribe(
      onError: { e in
        print("create failed: \(e)")
      }, onCompleted: { [weak self] in
        print("create ok")
        self?.scene.gistCreated()
      })
      .addDisposableTo(bag)
  }
}
