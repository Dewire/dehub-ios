//
//  RoundedCornerView.swift
//  DeHub
//
//  Created by Kalle Lindström on 06/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit

class RoundedCornerView: UIView {
  
  fileprivate static let CORNER_RADIUS: CGFloat = 5.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  fileprivate func setup() {
    layer.cornerRadius = RoundedCornerView.CORNER_RADIUS
    alpha = 0.8
  }

}
