//
//  UIView.swift
//  DeHub
//
//  Created by Kalle Lindström on 03/07/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit

// Loading indicator
extension UIView {
  
  func showLoadingIndicator(style: UIActivityIndicatorViewStyle = .white, color: UIColor? = nil, zPosition: CGFloat = 0) {
    if let indicator = viewWithTag(555999) as? UIActivityIndicatorView {
      indicator.startAnimating()
    }
    else {
      let indicator = UIActivityIndicatorView(activityIndicatorStyle: style)
      indicator.tag = 555999
      indicator.layer.zPosition = zPosition
      indicator.hidesWhenStopped = true
      indicator.translatesAutoresizingMaskIntoConstraints = false
      
      if let color = color {
        indicator.color = color
      }
      
      addSubview(indicator)
      setConstraints(indicator: indicator)
      indicator.startAnimating()
    }
  }
  
  private func setConstraints(indicator: UIActivityIndicatorView) {
    let centerX = NSLayoutConstraint(
      item: self,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: indicator,
      attribute: .centerX,
      multiplier: 1,
      constant: 0)
    
    let centerY = NSLayoutConstraint(
      item: self,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: indicator,
      attribute: .centerY,
      multiplier: 1,
      constant: 0)
    
    addConstraint(centerX)
    addConstraint(centerY)
  }
  
  func hideLoadingIndicator() {
    if let indicator = viewWithTag(555999) as? UIActivityIndicatorView {
      indicator.stopAnimating()
    }
  }
}
