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

class ViewGistDirector : BaseDirector {
  
  let networkInteractor: P_NetworkInteractor
  
  // Stage outputs
  let gistText = Variable<String>("")
  let title = Variable<String>("")

  init(actions: ViewGistStage.Actions, networkInteractor: P_NetworkInteractor, gist: GistEntity) {
    self.networkInteractor = networkInteractor
    super.init()
    
    title.value = gist.file.filename
    fetchGistText(url: gist.file.raw_url)
  }
  
  private func fetchGistText(url: String) {
    networkInteractor.get(url: url, options: []).map { data in
      String(data: data, encoding: .utf8)!
    }
    .bindTo(gistText)
    .addDisposableTo(bag)
  }
}
