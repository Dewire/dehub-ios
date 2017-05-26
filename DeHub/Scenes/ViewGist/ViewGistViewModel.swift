//
//  ViewGistViewModel.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class ViewGistViewModel: ViewModel {

  struct Outputs {
    let title: Driver<String>
    let text: Driver<String>
  }
  
  let gist: GistEntity
  let api: GistApi

  init(services: Services, gist: GistEntity) {
    self.gist = gist
    self.api = services.api
  }

  func observe() -> Outputs {
    return Outputs(
      title: Driver.just(gist.file.filename),
      text: api.getText(forGist: gist)
        .spin().error().asDriver(onErrorJustReturn: "")
    )
  }
}
