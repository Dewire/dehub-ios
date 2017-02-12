//
//  CreateGistEntity.swift
//  DeHub
//
//  Created by Kalle Lindström on 19/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct CreateGistEntity {
  public let description: String
  public let isPublic: Bool
  public let file: CreateGistFileInfo
  
  public init(description: String, isPublic: Bool, file: CreateGistFileInfo) {
    self.description = description
    self.isPublic = isPublic
    self.file = file
  }
  
  public func jsonData() -> Data {
    return try! json().toJsonData()
  }
  
  public func json() -> JsonDict {
    return [
      "description": description,
      "public": isPublic,
      "files": [description: file.json()]
    ]
  }
}

public struct CreateGistFileInfo {
  public let content: String
  
  public init(content: String) {
    self.content = content
  }
  
  public func json() -> JsonDict {
    return [
      "content": content
    ]
  }
}

