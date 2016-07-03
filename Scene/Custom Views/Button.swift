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
  
  private static let CORNER_RADIUS: CGFloat = 5.0
  
  override var enabled: Bool {
    didSet {
      self.backgroundColor = enabled ? UIColor.orangeColor() : UIColor.lightClay()
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
  
  private func setup() {
    layer.cornerRadius = Button.CORNER_RADIUS
    contentEdgeInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
    titleLabel?.font = UIFont.boldSystemFontOfSize(15)
    backgroundColor = UIColor.orangeColor()
  }
}