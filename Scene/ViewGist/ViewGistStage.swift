//
//  ViewGistStage.swift
//  DeHub
//
//  Created by Kalle Lindström on 15/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewGistStage : DirectedViewController<ViewGistDirector> {
  
  @IBOutlet weak var textViewContainer: UIScrollView!
  weak var textView: DualScrollableTextView!
  
  static func create(_ directorFactory: @escaping (ViewGistStage) -> ViewGistDirector) -> ViewGistStage {
    let storyboard = UIStoryboard(name: "ViewGist", bundle: Bundle(for: CreateGistScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! ViewGistStage
  }
  
  override func bind(director: ViewGistDirector) {
    director.gistText.asDriver()
      .drive(textView.rx.text)
      .addDisposableTo(bag)
    
    director.title.asDriver()
      .drive(rx.title)
      .addDisposableTo(bag)
    
    observeShowLoadingIndicator(director: director)
  }
  
  private func observeShowLoadingIndicator(director: ViewGistDirector) {
    director.showLoadingIndicator.asDriver().drive(onNext: { [unowned self] show in
      if show {
        self.view.showLoadingIndicator(style: .whiteLarge, color: .gray, zPosition: 1)
      } else {
        self.view.hideLoadingIndicator()
      }
      })
      .addDisposableTo(bag)
  }
  
  override func viewDidLoad() {
    addTextView()
    super.viewDidLoad()
    textView.font = UIFont(name: "Menlo", size: 14)!
    textView.autocorrectionType = .no
  }
  
  private func addTextView() {
    textView = DualScrollableTextView()
    textViewContainer.addSubview(textView)
  }
  
}

extension ViewGistStage {
  
  struct Actions {
    //let username: ControlProperty<String>
    
  }
  
  var actions: Actions {
    return Actions()
  }
}
