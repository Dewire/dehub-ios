//
//  RequestHelper.swift
//  DeHub
//
//  Created by Kalle Lindström on 18/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

class RequestHelper {
  
  private var basicAuth = ""
  
  init() {}
  
  func setUsername(username: String, password: String) {
    basicAuth = basicAuthForUsername(username, password: password)
  }
  
  private func basicAuthForUsername(username: String, password: String) -> String {
    let data = (username + ":" + password).dataUsingEncoding(NSUTF8StringEncoding)
    let encoded = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    
    return "Basic " + encoded!
  }
  
  func makeLoginRequest(username: String, password: String) -> NSURLRequest {
    return GET("https://api.github.com/user")
      .addBasicAuth(basicAuthForUsername(username, password: password))
  }
  
  func GET(url: String) -> NSMutableURLRequest {
    return NSMutableURLRequest(URL: NSURL(string: url)!).addBasicAuth(basicAuth)
  }
}

extension NSMutableURLRequest {
  func addBasicAuth(basicAuth: String) -> NSMutableURLRequest {
    setValue(basicAuth, forHTTPHeaderField: "Authorization")
    return self
  }
}