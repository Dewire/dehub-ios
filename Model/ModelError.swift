//
//  ModelError.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-02-11.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation

public enum ModelError: Error {
  case JsonParseError
  case StringParseError
  case ResponseNot200Error(response: HTTPURLResponse)
}
