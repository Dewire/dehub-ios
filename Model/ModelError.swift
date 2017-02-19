//
//  ModelError.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-02-11.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation

struct ModelError: Error {
  enum ErrorKind {
    case jsonParseError
    case stringParseError
    case responseNot200
  }
  
  let kind: ErrorKind
  let hint: String
  let underlying: NSError?
  
  init(_ kind: ErrorKind, hint: String = "", underlying: NSError? = nil) {
    self.kind = kind
    self.hint = hint
    self.underlying = underlying
  }
}
