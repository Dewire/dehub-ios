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

class ViewGistStage: DirectedViewController {
  
  @IBOutlet weak var textViewContainer: UIScrollView!
  weak var textView: DualScrollableTextView!
  
  static func create() -> ViewGistStage {
    let storyboard = UIStoryboard(name: "ViewGist", bundle: Bundle(for: CreateGistScene.self))
    return storyboard.instantiateInitialViewController() as! ViewGistStage
  }
  
  func setText(text: String) {
    textView.text = text
  }
  
  override func viewDidLoad() {
    addTextView()
    super.viewDidLoad()
  }
  
  private func addTextView() {
    textView = DualScrollableTextView()
    textView.font = UIFont(name: "Menlo", size: 14)!
    textView.autocorrectionType = .no
    textView.isEditable = false
    textViewContainer.addSubview(textView)
  }
}

