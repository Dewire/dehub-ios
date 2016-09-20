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

class CreateGistDirector : BaseDirector {
  
  // Scene outputs
  let gistCreated = PublishSubject<Void>()
  
  // Stage outputs
  let enableSaveButton = Variable<Bool>(false)
  
  private let networkInteractor: P_NetworkInteractor

  init(actions: CreateGistStage.Actions, networkInteractor: P_NetworkInteractor) {
    self.networkInteractor = networkInteractor
    super.init()
    
    observeActions(actions: actions)
  }
  
  private func observeActions(actions: CreateGistStage.Actions) {
    
    let gist = [actions.titleText, actions.contentText].combineLatest { texts -> CreateGistEntity? in
      guard !texts.contains("") else { return nil }
      return CreateGistEntity(
        description: texts[0],
        isPublic: false,
        file: CreateGistFileInfo(content: texts[1]))
    }
    
    observeEnableSaveButton(gist: gist)
    observeSaveGist(saveButtonTapped: actions.saveButtonTapped, gist: gist)
  }
  
  private func observeEnableSaveButton(gist: Observable<CreateGistEntity?>) {
    gist.map { $0 != nil }
      .bindTo(enableSaveButton)
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
    networkInteractor.create(gist: gist, options: []).subscribe(
      onError: { e in
        print("create failed: \(e)")
      }, onCompleted: { [weak self] in
        print("create ok")
        self?.gistCreated.onNext(())
      })
      .addDisposableTo(bag)
  }
}
