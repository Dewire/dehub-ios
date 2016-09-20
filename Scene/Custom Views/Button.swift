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
  
  private static let DEFAULT_COLOR = UIColor.orange
  
  private var activeColor: UIColor?
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        backgroundColor = activeColor ?? backgroundColor
      }
      else {
        guard oldValue else { return }
        activeColor = backgroundColor
        backgroundColor = UIColor.lightClay()
      }
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
    setTitleColor(UIColor.white, for: UIControlState())
    setTitleColor(UIColor.white, for: UIControlState.highlighted)
    titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    
    activeColor = backgroundColor ?? Button.DEFAULT_COLOR
    backgroundColor = isEnabled ? activeColor : UIColor.lightClay()
  }
}
