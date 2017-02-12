//
//  Dictionary.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-02-12.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation

extension Dictionary {
  
  func toJsonData() throws -> Data {
    return try JSONSerialization.data(withJSONObject: self, options: .init(rawValue: 0))
  }
}
