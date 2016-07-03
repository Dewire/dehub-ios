//
//  HomeStage.swift
//  DeHub
//
//  Created by Kalle Lindström on 21/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeStage : DirectedViewController<HomeDirector> {
  
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var reposCount: UILabel!
  @IBOutlet weak var gistsCount: UILabel!
  
  static func create(directorFactory: HomeStage -> HomeDirector) -> HomeStage {
    let storyboard = UIStoryboard(name: "Home", bundle: NSBundle(forClass: HomeScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! HomeStage
  }
}

extension HomeStage {
  
  struct Actions {
    let username: AnyObserver<String>
    let reposCount: AnyObserver<String>
    let gistsCount: AnyObserver<String>
  }
  
  var actions: Actions {
    return Actions(
      username: username.rx_text,
      reposCount: reposCount.rx_text,
      gistsCount:  gistsCount.rx_text
    )
  }
}