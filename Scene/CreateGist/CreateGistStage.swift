//
//  CreateGistStage.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateGistStage : DirectedViewController<CreateGistDirector> {
  
  static func create(_ directorFactory: @escaping (CreateGistStage) -> CreateGistDirector) -> CreateGistStage {
    let storyboard = UIStoryboard(name: "CreateGist", bundle: Bundle(for: CreateGistScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! CreateGistStage
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func bindDirector(_ director: CreateGistDirector) {
  }

}

extension CreateGistStage {

  struct Actions {
    //let username: ControlProperty<String>

  }

  var actions: Actions {
    return Actions()
  }
}
