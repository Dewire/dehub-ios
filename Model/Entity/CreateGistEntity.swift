//
//  CreateGistEntity.swift
//  DeHub
//
//  Created by Kalle Lindström on 19/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import Gloss

public struct CreateGistEntity {
  public let description: String
  public let isPublic: Bool
  public let file: CreateGistFileInfo
  
  public init(description: String, isPublic: Bool, file: CreateGistFileInfo) {
    self.description = description
    self.isPublic = isPublic
    self.file = file
  }
}

extension CreateGistEntity : Encodable {
  public func toJSON() -> JSON? {
    guard let file = file.toJSON() else { return nil }
    
    return jsonify([
      "description" ~~> description,
      "public" ~~> isPublic,
      "files" ~~> [description: file]
    ])
  }
}

public struct CreateGistFileInfo {
  public let content: String
  
  public init(content: String) {
    self.content = content
  }
}

extension CreateGistFileInfo : Encodable {
  public func toJSON() -> JSON? {
    return jsonify([
      "content" ~~> content,
    ])
  }
}
