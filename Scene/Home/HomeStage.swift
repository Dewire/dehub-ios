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
  
  
  static func create(_ directorFactory: @escaping (HomeStage) -> HomeDirector) -> HomeStage {
    let storyboard = UIStoryboard(name: "Home", bundle: Bundle(for: HomeScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! HomeStage
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupBarButtons()
  }
  
  fileprivate func setupBarButtons() {
    let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    self.navigationItem.rightBarButtonItem = item
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension HomeStage {
  
  struct Actions {
    let addButtonTap: ControlEvent<Void>
  }
  
  var actions: Actions {
    return Actions(
      addButtonTap: self.navigationItem.rightBarButtonItem!.rx.tap
    )
  }
}
