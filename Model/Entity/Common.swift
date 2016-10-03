//
//  Common.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/10/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

postfix operator *!

struct UnwrappedNilError: Error { }

extension Optional {
  
  static postfix func *! (o: Optional<Wrapped>) throws -> Wrapped {
    guard let value = o else { throw UnwrappedNilError() }
    return value
  }
}


public typealias JsonDict = [String : Any]
