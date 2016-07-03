//
//  UIView.swift
//  DeHub
//
//  Created by Kalle Lindström on 03/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit

extension UIView {
  
  var isAnimating: Bool {
    get {
    	return layer.animationKeys()?.count > 0
    }
  }
}
