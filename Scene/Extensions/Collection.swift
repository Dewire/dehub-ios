//
//  Collection.swift
//  DeHub
//
//  Created by Kalle Lindström on 28/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

extension Collection {
  
  func groupBy(predicate: (Self.Iterator.Element) -> Bool) ->
    (match: [Self.Iterator.Element], noMatch: [Self.Iterator.Element]) {
      
    var match: [Self.Iterator.Element] = []
    var noMatch: [Self.Iterator.Element] = []
    
    for e in self {
      if predicate(e) {
        match.append(e)
      } else {
        noMatch.append(e)
      }
    }
    
    return (match, noMatch)
  }
}
