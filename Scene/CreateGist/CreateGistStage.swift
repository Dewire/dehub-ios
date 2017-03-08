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

class CreateGistStage: DirectedViewController {
  
  @IBOutlet weak var titleText: UITextField!
  @IBOutlet weak var contentText: UITextView!
  @IBOutlet weak var privatePublicSegment: UISegmentedControl!
  
  static func create() -> CreateGistStage {
    let storyboard = UIStoryboard(name: "CreateGist", bundle: Bundle(for: CreateGistScene.self))
    return storyboard.instantiateInitialViewController() as! CreateGistStage
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let save = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: nil, action: nil)
    navigationItem.rightBarButtonItem = save
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func enableSaveButton(_ isEnabled: Bool) {
    navigationItem.rightBarButtonItem?.isEnabled = isEnabled
  }
}

extension CreateGistStage {

  struct Outputs {
    let saveButtonTapped: ControlEvent<Void>
    let titleText: ControlProperty<String?>
    let contentText: ControlProperty<String?>
    let privatePublic: ControlProperty<Int>
  }

  var outputs: Outputs {
    return Outputs(
      saveButtonTapped: navigationItem.rightBarButtonItem!.rx.tap,
      titleText: titleText.rx.text,
      contentText: contentText.rx.text,
      privatePublic: privatePublicSegment.rx.value
    )
  }
}
