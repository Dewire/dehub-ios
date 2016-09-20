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
  
  @IBOutlet weak var titleText: UITextField!
  
  @IBOutlet weak var contentText: UITextView!
  
  static func create(_ directorFactory: @escaping (CreateGistStage) -> CreateGistDirector) -> CreateGistStage {
    let storyboard = UIStoryboard(name: "CreateGist", bundle: Bundle(for: CreateGistScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! CreateGistStage
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let save = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: nil, action: nil)
    navigationItem.rightBarButtonItem = save
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
 
  override func bind(director: CreateGistDirector) {
    director.enableSaveButton.asDriver()
      .drive(navigationItem.rightBarButtonItem!.rx.enabled)
      .addDisposableTo(bag)
  }

}

extension CreateGistStage {

  struct Actions {
    let saveButtonTapped: ControlEvent<Void>
    let titleText: ControlProperty<String>
    let contentText: ControlProperty<String>
  }

  var actions: Actions {
    return Actions(
      saveButtonTapped: navigationItem.rightBarButtonItem!.rx.tap,
      titleText: titleText.rx.text,
      contentText: contentText.rx.text
    )
  }
}
