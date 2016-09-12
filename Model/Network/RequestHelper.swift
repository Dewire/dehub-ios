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
  
  private var basicAuth = ""
  
  init(baseUrl: String) {
    self.baseUrl = baseUrl
  }
  
  func setUsername(username: String, password: String) {
    basicAuth = basicAuthForUsername(username, password: password)
  }
  
  private func basicAuthForUsername(username: String, password: String) -> String {
    let data = (username + ":" + password).dataUsingEncoding(NSUTF8StringEncoding)
    let encoded = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    
    return "Basic " + encoded!
  }
  
  func makeLoginRequest(username: String, password: String) -> NSURLRequest {
    return GET("user")
      .addBasicAuth(basicAuthForUsername(username, password: password))
  }
  
  func GET(path: String) -> NSMutableURLRequest {
    precondition(!path.isEmpty && path.characters.first != "/")
    
    let url = NSURL(string: baseUrl + "/" + path)!
    print(url)
    return NSMutableURLRequest(URL: url).addBasicAuth(basicAuth)
  }
}

extension NSMutableURLRequest {
  func addBasicAuth(basicAuth: String) -> NSMutableURLRequest {
    setValue(basicAuth, forHTTPHeaderField: "Authorization")
    return self
  }
}