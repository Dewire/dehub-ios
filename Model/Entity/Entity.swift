//
//  Entity.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/10/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK: Entity

/**
 An Entity is something that can be parsed from a JSON object.
 */
public protocol Entity {
  init(json: JSON) throws
  
  /**
   Given a JSON object that is JSON array, returns an array of [Self]
   If the JSON object is not an array, or it could not be parsed correctly,
   a JsonParseError is thrown.
  */
  static func parse(fromJSONArray: JSON) throws -> [Self]
}

extension Entity {
  public static func parse(fromJSONArray json: JSON) throws -> [Self] {
    guard let array = json.array else { throw ModelError.JsonParseError }
    return try array.map(Self.init)
  }
}

//MARK: JSON parsing

public typealias JsonDict = [String : Any]


/**
 A helper operator for parsing JSON.
 Works like ! for Optionals, but if there is no value it will not trap but
 instead throw a JsonParseError.
 */
postfix operator *!

extension Optional {

  static postfix func *! (o: Optional<Wrapped>) throws -> Wrapped {
    guard let value = o else { throw ModelError.JsonParseError }
    return value
  }
}
