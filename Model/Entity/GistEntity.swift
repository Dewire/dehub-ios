//
//  GistEntity.swift
//  DeHub
//
//  Created by Kalle Lindström on 12/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct GistEntity {
  public let description: String
  public let isPublic: Bool
  public let file: GistFileInfo
}

extension GistEntity {
  
  public init(json: JSON) throws {
    
    description = try json["description"].string*!
    isPublic = try json["public"].bool*!
    
    file = try GistFileInfo(json: json["files"].dictionary*!.first*!.value*!)
  }
}

public struct GistFileInfo {
  public let size: Int
  public let raw_url: String
  public let filename: String
  public let language: String?
}

extension GistFileInfo {
  
  public init(json: JSON) throws {
    size = try json["size"].int*!
    raw_url = try json["raw_url"].string*!
    filename = try json["filename"].string*!
    language = json["language"].string
  }
}
