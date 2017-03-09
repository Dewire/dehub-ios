//
//  Entity.swift
//  DeHub
//
//  Created by Kalle Lindström on 01/10/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: Entity

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
    guard let array = json.array else {
      throw ModelError(.jsonParseError, hint: json.debugDescription, underlying: json.error)
    }
    return try array.map(Self.init)
  }
}

// MARK: JSON parsing

public typealias JsonDict = [String : Any]


/**
 A helper operator for parsing JSON.
 Works like ! for Optionals, but if there is no value it will not trap but
 instead throw a JsonParseError.
 */
postfix operator *!

extension Optional {
  
  static postfix func *! (o: Wrapped?) throws -> Wrapped {
    guard let value = o else {
      throw ModelError(.jsonParseError, hint: o.customMirror.description)
    }
    return value
  }
}

/**
 Archivable is a protocol that types can implement if they should support being persisted to disk
 using NSKeyedArchiver. See State for examples.
 */
protocol Archivable {
  /**
   Initializer that takes a Data object that was produces from archive() method.
  */
  init(data: Data)
  
  /**
   Archives self into a Data object using some method (most likely NSKeyedArchiver, but this is not required)
  */
  func archive() -> Data
}
