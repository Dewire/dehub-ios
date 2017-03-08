//
//  RestService.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-01-21.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift

public typealias RestResponse = (response: HTTPURLResponse, data: Data)

class RestService {
  
  var invalidateNextCache = false
  
  fileprivate let baseUrl: URL
  
  fileprivate let defaultCachePolicy: URLRequest.CachePolicy
  
  fileprivate let defaultTimeout: TimeInterval
  
  fileprivate var standardHeaders = [String: String]()
  
  fileprivate var cachePolicy: URLRequest.CachePolicy {
    if invalidateNextCache {
      invalidateNextCache = false
      return .reloadIgnoringLocalCacheData
    } else {
      return defaultCachePolicy
    }
  }
  
  init(baseUrl: String,
       cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
       timeout: Double = 10) {
    
    if let url = URL(string: baseUrl) {
      self.baseUrl = url
    } else {
      fatalError("invalid baseUrl: \(baseUrl)")
    }
    
    self.defaultCachePolicy = cachePolicy
    self.defaultTimeout = timeout
  }
  
  //MARK: POST
  func post<T>(
    _ path: String,
    body: Data?,
    requestTransform: ((URLRequest) -> URLRequest)? = nil,
    responseTransform: @escaping (RestResponse) throws -> T
    ) -> Observable<T> {
    
    let req = transform(request: postRequest(path: path, body: body),
                        transform: requestTransform)
    
    return rxResponse(req)
      .map(responseTransform)
      .observeOn(MainScheduler.instance)
  }
  
  func post(
    _ path: String,
    body: Data?,
    requestTransform: ((URLRequest) -> URLRequest)? = nil
    ) -> Observable<RestResponse> {
    
    let req = transform(request: postRequest(path: path, body: body),
                        transform: requestTransform)
    
    return rxResponse(req)
      .observeOn(MainScheduler.instance)
  }
  
  private func postRequest(path: String, body: Data?) -> URLRequest {
    var req = requestWithStandardHeaders(forPath: path)
    req.httpMethod = "POST"
    req.httpBody = body
    return req
  }
  
  //MARK: GET
  func get<T>(
    _ path: String,
    requestTransform: ((URLRequest) -> URLRequest)? = nil,
    responseTransform: @escaping (RestResponse) throws -> T
    ) -> Observable<T> {
    
    let req = transform(request: getRequest(path: path),
                        transform: requestTransform)
    
    return rxResponse(req)
      .map(responseTransform)
      .observeOn(MainScheduler.instance)
  }
  
  func get(
    _ path: String,
    requestTransform: ((URLRequest) -> URLRequest)? = nil
    ) -> Observable<RestResponse> {
    
    let req = transform(request: getRequest(path: path),
                        transform: requestTransform)
    
    return rxResponse(req)
      .observeOn(MainScheduler.instance)
  }
  
  private func getRequest(path: String) -> URLRequest {
    return requestWithStandardHeaders(forPath: path)
  }
  
  //MARK: Helpers
  private func transform(request: URLRequest, transform: ((URLRequest) -> URLRequest)?) -> URLRequest {
    guard let transform = transform else { return request }
    return transform(request)
  }
  
  private func rxResponse(_ req: URLRequest) -> Observable<RestResponse> {
    return URLSession.shared.rx.response(request: req).map { (response, data) in
      RestResponse(response: response, data: data)
    }
  }
  
  private func requestWithStandardHeaders(forPath path: String) -> URLRequest {
    var req = request(forPath: path)
    req.allHTTPHeaderFields = standardHeaders
    return req
  }
  
  private func request(forPath path: String) -> URLRequest {
    return URLRequest(url: url(forPath: path),
                      cachePolicy: cachePolicy,
                      timeoutInterval: defaultTimeout)
  }
  
  func url(forPath path: String) -> URL {
    if path.hasPrefix("https://") || path.hasPrefix("http://") {
      return URL(string: path)!
    } else {
      return URL(string: path, relativeTo: baseUrl)!
    }
  }
}


//MARK: Basic auth
extension RestService {
  func setBasicAuth(username: String, password: String) {
    standardHeaders["Authorization"] = basicAuthFor(username: username, password: password)
  }
  
  private func basicAuthFor(username: String, password: String) -> String {
    let data = (username + ":" + password).data(using: String.Encoding.utf8)
    let encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    return "Basic " + encoded!
  }
}


//MARK: ObservableType extensions
extension ObservableType where E == RestResponse {
  
  func validateIs200() -> Observable<RestResponse> {
    return map { res in
      guard 200..<300 ~= res.response.statusCode else {
        throw ModelError(.responseNot200, hint: res.response.debugDescription)
      }
      return res
    }
  }
}




