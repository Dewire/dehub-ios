//
//  GistTableViewCell.swift
//  DeHub
//
//  Created by Kalle Lindström on 13/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit

class GistTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var languageLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
