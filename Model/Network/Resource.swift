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

/**
 Use this function in cases where the RestResponse should not be parsed to
 something else.
 */
func noParse(response: RestResponse) -> RestResponse {
  return response
}

/**
 A factory that contains common state that is used when creating Resources.
 */
class ResourceFactory {

  let baseUrl: URL
  let defaultCachePolicy: URLRequest.CachePolicy
  let defaultTimeout: TimeInterval
  var standardHeaders = [String: String]()
  
  /// Set this to true in order to invalidate the cache for the next Resource that is
  /// created from this ResourceFactory instance.
  var invalidateNextCache = false
  
  var cachePolicy: URLRequest.CachePolicy {
    if invalidateNextCache {
      invalidateNextCache = false
      return .reloadIgnoringLocalCacheData
    } else {
      return defaultCachePolicy
    }
  }
  
  init(baseUrl: String,
       cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
       timeout: TimeInterval = 10) {
    
    if let url = URL(string: baseUrl) {
      self.baseUrl = url
    } else {
      fatalError("invalid baseUrl: \(baseUrl)")
    }
    
    self.defaultCachePolicy = cachePolicy
    self.defaultTimeout = timeout
  }
  
  /**
   Creates a new Resource for the path. The parse closure is used to parse the response.
   If the RestResponse shouldn't be parsed the noParse function can be used a convenicence.
   If the path url is an absolute URL (starting with http/https) it will be used directly.
   Otherwise it will be appended as a path component to the base url.
   The default HTTP method is GET.
  */
  func resource<A>(_ path: String, parse: @escaping ((RestResponse) throws -> A)) -> Resource<A> {
    return Resource(url: url(forPath: path),
                    parse: parse,
                    httpMethod: "GET",
                    headers: standardHeaders,
                    timeout: defaultTimeout,
                    cachePolicy: cachePolicy,
                    body: nil,
                    _customResponse: nil)
  }
  
  func url(forPath path: String) -> URL {
    if path.hasPrefix("https://") || path.hasPrefix("http://") {
      return URL(string: path)!
    } else {
      return URL(string: path, relativeTo: baseUrl)!
    }
  }
}

// MARK: Basic auth

extension ResourceFactory {
  func setBasicAuth(username: String, password: String) {
    standardHeaders["Authorization"] = basicAuthFor(username: username, password: password)
  }
  
  private func basicAuthFor(username: String, password: String) -> String {
    let data = (username + ":" + password).data(using: String.Encoding.utf8)
    let encoded = data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    return "Basic " + encoded!
  }
}

// MARK: Resource

struct Resource<A> {
  let url: URL
  let parse: ((RestResponse) throws -> A)
  
  var httpMethod: String
  var headers: [String: String]
  var timeout: Double
  var cachePolicy: URLRequest.CachePolicy
  var body: Data?
 
  // For mocking
  var _customResponse: Observable<A>?
}

extension Resource {
  func load() -> Observable<A> {
    
    if let custom = _customResponse {
      return custom
    }
    
    let req = request(forUrl: url)
    
    return rxResponse(req)
      .map(parse)
      .observeOn(MainScheduler.instance)
  }
  
  private func request(forUrl url: URL) -> URLRequest {
    var req = URLRequest(url: url,
                         cachePolicy: cachePolicy,
                         timeoutInterval: timeout)
    
    req.httpMethod = httpMethod
    req.allHTTPHeaderFields = headers
    req.timeoutInterval = timeout
    req.cachePolicy = cachePolicy
    req.httpBody = body
    
    return req
  }
  
  private func rxResponse(_ req: URLRequest) -> Observable<RestResponse> {
    return URLSession.shared.rx.response(request: req).map { (response, data) in
      RestResponse(response: response, data: data)
    }
  }
}

// MARK: ObservableType extensions

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
