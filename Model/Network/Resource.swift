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

enum CacheTimeInterval: Int {
  case oneMinute = 60, fiveMinutes = 300, tenMinutes = 600, twentyMinutes = 1200, oneHour = 3600
}

/**
 Use this function in cases where the RestResponse should not be parsed to
 something else.
 */
func noParse(response: RestResponse) -> RestResponse {
  return response
}

/**
 A factory that contains common state that is used when creating Resources.
 
 This class supports using a caching policy on a per Resource base.
 The cache policy can either be specified using the standard HTTP cache control headers,
 which works out of the box. If the HTTP cache control headers can't be used for some
 reason (for example we don't have control over the server) this class also supports
 setting a cache timeout. If a Resource is loaded before the cache timeout has expired it will
 return a cached response if one is available. Setting a cache timeout takes precendence
 over using the HTTP cache control headers.
 */
class ResourceFactory {

  let baseUrl: URL
  let defaultCachePolicy: URLRequest.CachePolicy
  let defaultTimeout: TimeInterval
  var standardHeaders = [String: String]()
  
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
   If the RestResponse shouldn't be parsed the noParse function can be used a convenience.
   If the path url is an absolute URL (starting with http/https) it will be used directly.
   Otherwise it will be appended as a path component to the base url.
   The default HTTP method is GET.
  */
  func resource<A>(_ path: String,
                   cacheInterval: CacheTimeInterval? = nil,
                   invalidateCache: Bool = false,
                   parse: @escaping ((RestResponse) throws -> A)) -> Resource<A> {
    
    let u = url(forPath: path)
    let policy = cachePolicy(forUrl: u, cacheInterval: cacheInterval, invalidateCache: invalidateCache)
    
    return Resource(url: u,
                    parse: parse,
                    httpMethod: "GET",
                    headers: standardHeaders,
                    timeout: defaultTimeout,
                    cachePolicy: policy,
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

// MARK: Caching

extension ResourceFactory {
  
  func cachePolicy(
    forUrl url: URL,
    cacheInterval: CacheTimeInterval?,
    invalidateCache: Bool = false) -> URLRequest.CachePolicy {
    
    // The path without any query parameters
    let resourcePath = url.absoluteString.components(separatedBy: "?").first
    
    // First check if the cache for this request is invalidated
    guard !invalidateCache else {
      updateExpiration(cacheInterval: cacheInterval, forResourcePath: resourcePath)
      return .reloadIgnoringLocalCacheData
    }

    // If we don't have a cache interval or a path we use the default cache policy
    guard let interval = cacheInterval, let path = resourcePath else {
      return defaultCachePolicy
    }
    
    let now = Date()
    
    // Check if a resource expiration date exists in the future
    if let expiration = UserDefaults.standard.object(forKey: path) as? Date, expiration >= now {
      print("Returning cached response (if available) for \(path)" +
        " | Cache expires in \(Int(expiration.timeIntervalSince1970 - now.timeIntervalSince1970))s")
      
      return .returnCacheDataElseLoad
    } else {
      updateExpiration(cacheInterval: interval, forResourcePath: path)
      return defaultCachePolicy
    }
  }
  
  private func updateExpiration(cacheInterval: CacheTimeInterval?, forResourcePath path: String?) {
    guard let interval = cacheInterval, let path = path else { return }
    
    let nextExpiration = Date().addingTimeInterval(TimeInterval(interval.rawValue))
    UserDefaults.standard.set(nextExpiration, forKey: path)
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
