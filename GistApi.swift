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
  
  private let restService: RestService
  
  private let state: State
  
  init(restService: RestService, state: State) {
    self.restService = restService
    self.state = state
  }
  
  /**
   Tries to log in with the given username and password.
   If the log in is successful true will be emitted.
   If the log in fails because of bad credentials the false will be emitted.
   If a network error occurs the error will be emitted.
   */
  public func login(username: String, password: String) -> Observable<Bool> {
    restService.setBasicAuth(username: username, password: password)
    
    return restService.get("gists").map { res in
      200..<300 ~= res.response.statusCode
    }
  }
  
  public func logout() {
    restService.setBasicAuth(username: "", password: "")
  }
  
  public func loadGists() -> Observable<Void> {
    
    return restService.get("gists") { response -> [GistEntity] in
      return try GistEntity.parse(fromJSONArray: JSON(data: response.data))
    }
    .connect(state._gists)
    .map { _ in () }
  }
  
  public func getText(forGist gist: GistEntity) -> Observable<String> {
    return restService.get(gist.file.raw_url) { response -> String in
      guard let string = String(data: response.data, encoding: .utf8) else {
        throw ModelError(.stringParseError)
      }
      return string
    }
  }
  
  public func create(gist: CreateGistEntity) -> Observable<Void> {
    return restService.post("gists", body: gist.jsonData()).validateIs200().toVoid()
  }
}

fileprivate extension ObservableType {
  func connect(_ variable: Variable<E>) -> Observable<Self.E> {
    return self.do(onNext: { value in
      variable.value = value
    })
  }
}
