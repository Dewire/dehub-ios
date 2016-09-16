//
//  RequestHelper.swift
//  DeHub
//
//  Created by Kalle Lindström on 18/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

class RequestHelper {
  
  let baseUrl: String
  
  fileprivate var basicAuth = ""
  
  init(baseUrl: String) {
    self.baseUrl = baseUrl
  }
  
  func setUsername(_ username: String, password: String) {
    basicAuth = basicAuthForUsername(username, password: password)
  }
  
  fileprivate func basicAuthForUsername(_ username: String, password: String) -> String {
    let data = (username + ":" + password).data(using: String.Encoding.utf8)
    let encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    
    return "Basic " + encoded!
  }
  
  func makeLoginRequest(_ username: String, password: String) -> URLRequest {
    return GET("user")
      .addBasicAuth(basicAuthForUsername(username, password: password)) as URLRequest
  }
  
  func GET(_ path: String, relativePath: Bool = true) -> NSMutableURLRequest {
    precondition(!path.isEmpty)
    if relativePath { precondition(path.characters.first != "/") }
    
    
    let url = URL(string: relativePath ? baseUrl + "/" + path : path)!
    print(url)
    return NSMutableURLRequest(url: url).addBasicAuth(basicAuth)
  }
}

extension NSMutableURLRequest {
  func addBasicAuth(_ basicAuth: String) -> NSMutableURLRequest {
    setValue(basicAuth, forHTTPHeaderField: "Authorization")
    return self
  }
}
