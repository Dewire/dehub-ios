//: Playground - noun: a place where people can play

import UIKit

extension UIView {
  
  func showLoadingIndicator() {
    if let indicator = viewWithTag(555999) as? UIActivityIndicatorView {
      indicator.startAnimating()
    }
    else {
      let indicator = UIActivityIndicatorView()
      indicator.tag = 555999
      indicator.hidesWhenStopped = true
      indicator.translatesAutoresizingMaskIntoConstraints = false
      setConstraints(indicator: indicator)
      addSubview(indicator)
    }
  }
  
  private func setConstraints(indicator: UIActivityIndicatorView) {
    let centerX = NSLayoutConstraint(
      item: indicator,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1,
      constant: 0)
    
    let centerY = NSLayoutConstraint(
      item: indicator,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: self,
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


let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

view.showLoadingIndicator()

view