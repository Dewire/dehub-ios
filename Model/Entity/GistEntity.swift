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

extension GistEntity: Entity {
  
  public init(json: JSON) throws {
    description = json["description"].string ?? ""
    isPublic = try json["public"].bool*!
    file = try GistFileInfo(json: json["files"].dictionary*!.first*!.value*!)
  }
}

extension GistEntity: Archivable {
  init(data: Data) {
    let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
    description = dic["description"] as! String
    isPublic = dic["public"] as! Bool
    file = GistFileInfo(data: dic["file"] as! Data)
  }
  
  func archive() -> Data {
    var dic = [String: Any]()
    dic["description"] = description
    dic["public"] = isPublic
    dic["file"] = file.archive()
    return NSKeyedArchiver.archivedData(withRootObject: dic)
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

extension GistFileInfo: Archivable {
  init(data: Data) {
    let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
    size = dic["size"] as! Int
    raw_url = dic["raw_url"] as! String
    filename = dic["filename"] as! String
    language = dic["language"] as? String
  }
  
  func archive() -> Data {
    var dic = [String: Any]()
    dic["size"] = size
    dic["raw_url"] = raw_url
    dic["filename"] = filename
    dic["language"] = language
    return NSKeyedArchiver.archivedData(withRootObject: dic)
  }
}
