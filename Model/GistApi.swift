//
//  GistApi.swift
//  DeHub
//
//  Created by Kalle Lindström on 29/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import Siesta
import SwiftyJSON

public class GistApi: Service {
  
  static let BASE_URL = "https://api.github.com"
  
  private let SwiftyJSONTransformer = ResponseContentTransformer {
    JSON($0.content as AnyObject)
  }
  
  fileprivate var authToken = "" {
    didSet {
      // Rerun existing configuration closure using new value
      invalidateConfiguration()
      
      // Wipe any Siesta’s cached state if auth token changes
      wipeResources()
    }
  }
  
  init(networkProvider: NetworkingProvider? = nil) {
    if let provider = networkProvider {
      super.init(baseURL: GistApi.BASE_URL, useDefaultTransformers: true, networking: provider)
    }
    else {
      super.init(baseURL: GistApi.BASE_URL)
    }
    
    setup()
  }
  
  private func setup() {
    
    Siesta.enabledLogCategories = LogCategory.common
    
    configure { [weak self] in
      guard let s = self else { return }
      
      $0.headers["Authorization"] = s.authToken
      $0.pipeline[.parsing].add(s.SwiftyJSONTransformer, contentTypes: ["*/json"])
    }
    
    configureTransformer("/gists") {
      try ($0.content as JSON).arrayValue.map(GistEntity.init)
    }
  }
}

extension GistApi {
  
  public func login(username: String, password: String) -> Request {
    authToken = basicAuthFor(username: username, password: password)
    return gists.request(.get)
  }
  
  public func logout() {
    authToken = ""
  }
  
  private func basicAuthFor(username: String, password: String) -> String {
    let data = (username + ":" + password).data(using: String.Encoding.utf8)
    let encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    return "Basic " + encoded!
  }
  
  public func get(url: String) -> Request {
    return resource(absoluteURL: url).request(.get)
  }
  
  public var gists: Resource {
    return resource("/gists")
  }
}

