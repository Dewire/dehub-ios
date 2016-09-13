//
//  Button.swift
//  DeHub
//
//  Created by Kalle Lindström on 02/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Button: UIButton {
  
  fileprivate static let CORNER_RADIUS: CGFloat = 5.0
  
  override var isEnabled: Bool {
    didSet {
      self.backgroundColor = isEnabled ? UIColor.orange : UIColor.lightClay()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  fileprivate func setup() {
    layer.cornerRadius = Button.CORNER_RADIUS
    contentEdgeInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    setTitleColor(UIColor.white, for: UIControlState())
    setTitleColor(UIColor.white, for: UIControlState.highlighted)
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    backgroundColor = UIColor.orange
  }
}
