//
//  GistEntity.swift
//  DeHub
//
//  Created by Kalle Lindström on 12/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import Gloss

public struct GistEntity : Decodable {
  
  public let description: String?
  
  public init?(json: JSON) {
    self.description = "description" <~~ json
  }
}