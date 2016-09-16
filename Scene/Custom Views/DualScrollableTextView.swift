//
//  DualScrollableTextView.swift
//  DeHub
//
//  Created by Kalle Lindström on 16/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit

class DualScrollableTextView: UITextView {
  
  override var text: String! {
    didSet {
      setNewFrame(forText: text)
    }
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    isScrollEnabled = false
  }
  
  private func setNewFrame(forText: String) {
    let maxSize = CGSize(width: Int.max, height: Int.max)
    
    let boundingRect = (forText as NSString).boundingRect(
      with: maxSize,
      options: NSStringDrawingOptions.usesLineFragmentOrigin,
      attributes: [NSFontAttributeName : font!],  // must unwrap font here or we crash
      context: nil)
    
    let newFrame = CGRect(
      origin: frame.origin,
      size: CGSize(width: boundingRect.width, height: boundingRect.height))
    
    frame = newFrame
    setParentContentSize(boundingRect.size)
  }
  
  private func setParentContentSize(_ size: CGSize) {
    if let parent = superview as? UIScrollView {
      
      parent.contentSize = CGSize(
        width: size.width + parent.contentInset.left,
        height: size.height + parent.contentInset.top)
    }
  }

}
