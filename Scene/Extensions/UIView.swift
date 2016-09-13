//
//  UIView.swift
//  DeHub
//
//  Created by Kalle Lindström on 03/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension UIView {
  
  var isAnimating: Bool {
    get {
    	return layer.animationKeys()?.count > 0
    }
  }
}
