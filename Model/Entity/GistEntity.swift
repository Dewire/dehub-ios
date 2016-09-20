//
//  GistEntity.swift
//  DeHub
//
//  Created by Kalle Lindström on 12/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import Gloss

public struct GistEntity {
  public let description: String
  public let file: GistFileInfo
}

extension GistEntity : Decodable {
  public init?(json: JSON) {
    self.description = "description" <~~ json ?? ""
    
    if let files = json["files"] as? JSON,
      let first = files[files.keys.first!] as? JSON,
      let file = GistFileInfo(json: first) {
        self.file = file
      }
    else {
      return nil
    }
  }
}

public struct GistFileInfo {
  public let size: Int
  public let raw_url: String
  public let filename: String
  public let language: String?
}

extension GistFileInfo : Decodable {
  public init?(json: JSON) {
    
    guard
      let size: Int = "size" <~~ json,
      let raw_url: String = "raw_url" <~~ json,
      let filename: String = "filename" <~~ json else { return nil }
    
    
    self.size = size
    self.raw_url = raw_url
    self.filename = filename
    self.language = "language" <~~ json
  }
}
