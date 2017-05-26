//
//  CreateGistViewModel.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class CreateGistViewModel: ViewModel {

  struct Outputs {
    let saveButtonEnabled: Driver<Bool>
    let showGistCreated: Driver<Void>
  }

  struct Inputs {
    let saveButtonTapped: ControlEvent<Void>
    let titleText: ControlProperty<String?>
    let contentText: ControlProperty<String?>
    let privatePublic: ControlProperty<Int>
  }

  private let api: GistApi

  init(services: Services) {
    self.api = services.api
  }

  func observe(inputs: Inputs) -> Outputs {

    let gist = gistDriver(inputs)
    let validGist = gist.map { $0 != nil }

    let saveDriver = inputs.saveButtonTapped.asDriver()
    let gistCreatedState = saveDriver.triggeredProgress(fromSource: gist.withoutNils()) { gist in
      self.api.create(gist: gist)
        .spin().error()
        .map { _ in true }
    }

    let saveButtonEnabled = Driver.combineLatest(validGist, gistCreatedState) { valid, createdState -> Bool in
      if case .inProgress = createdState {
        return false
      } else {
        return valid
      }
    }

    let showGistCreated = gistCreatedState.filter { state in
      if case .completed(let ok) = state {
        return ok
      }
      return false
    }.toVoid()

    return Outputs(
      saveButtonEnabled: saveButtonEnabled,
      showGistCreated: showGistCreated
    )
  }

  private func gistDriver(_ inputs: Inputs) -> Driver<CreateGistEntity?> {
    return Driver.combineLatest(
      inputs.titleText.asDriver().withoutNils(),
      inputs.contentText.asDriver().withoutNils(),
      inputs.privatePublic.asDriver()) { title, content, isPublic -> CreateGistEntity? in

      guard !title.isEmpty && !content.isEmpty else { return nil }

      return CreateGistEntity(
        description: title,
        isPublic: isPublic == 1,
        file: CreateGistFileInfo(content: content))
    }
  }
}
