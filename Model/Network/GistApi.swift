//
//  GistApi.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-01-21.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import SwiftyJSON

public class GistApi {
  
  private let resourceFactory: ResourceFactory
  
  private let state: State
  
  init(resourceFactory: ResourceFactory, state: State) {
    self.resourceFactory = resourceFactory
    self.state = state
  }
  
  /**
   Calling this method will make the cache policy for the next request to reloadIgnoringLocalCacheData
   (i.e. no cache). Only the upcoming request is altered -- requests after the next one will use the
   default cache policy.
  */
  @discardableResult public func invalidateNextCache() -> GistApi {
    resourceFactory.invalidateNextCache = true
    return self
  }
  
  /**
   Tries to log in with the given username and password.
   If the log in is successful true will be emitted.
   If the log in fails because of bad credentials the false will be emitted.
   If a network error occurs the error will be emitted.
   */
  public func login(username: String, password: String) -> Observable<Bool> {
    resourceFactory.setBasicAuth(username: username, password: password)
    
    return resourceFactory.resource("gists") { res in
      200..<300 ~= res.response.statusCode
    }
    .load()
  }
  
  public func logout() {
    resourceFactory.setBasicAuth(username: "", password: "")
  }
  
  public func loadGists() -> Observable<Void> {
    return resourceFactory.resource("gists", cacheInterval: .oneMinute) { res in
      try GistEntity.parse(fromJSONArray: JSON(data: res.data))
    }
    .load()
    .connect(state._gists)
    .map { _ in () }
  }
  
  public func getText(forGist gist: GistEntity) -> Observable<String> {
    return resourceFactory.resource(gist.file.raw_url) { res in
      guard let string = String(data: res.data, encoding: .utf8) else {
        throw ModelError(.stringParseError)
      }
      return string
    }
    .load()
  }
  
  public func create(gist: CreateGistEntity) -> Observable<Void> {
    var res = resourceFactory.resource("gists", parse: noParse)
    res.httpMethod = "POST"
    res.body = gist.jsonData()
    
    return res.load().validateIs200().toVoid()
  }
}

fileprivate extension ObservableType {
  func connect(_ variable: Variable<E>) -> Observable<Self.E> {
    return self.do(onNext: { value in
      variable.value = value
    })
  }
}
