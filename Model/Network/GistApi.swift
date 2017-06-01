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
  
  public func loadGists(force: Bool = false) -> Observable<Void> {
    return resourceFactory.resource("gists") { res in
      try GistEntity.parse(fromJSONArray: JSON(data: res.data))
    }
    .load()
    .connect(state._gists)
    .toVoid()
    .cacheInterval(key: "loadGists", interval: .oneMinute, invalidateCache: force)
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
    var res = resourceFactory.resource("gists") { newGist in
      try GistEntity(json: JSON(newGist.data))
    }
    res.httpMethod = "POST"
    res.body = gist.jsonData()
    
    return res.load()
      .connect(state._gists) { newGist, gists in
        [newGist] + gists
      }
      .toVoid()
  }
}

fileprivate extension ObservableType {

  func cacheInterval(key: String, interval: CacheTimeInterval, invalidateCache: Bool) -> Observable<E> {

    guard let expiration = UserDefaults.standard.object(forKey: key) as? Date, !invalidateCache else {
      updateExpiration(forKey: key, interval: interval)
      return asObservable()
    }

    if Date() >= expiration {
      updateExpiration(forKey: key, interval: interval)
      return asObservable()
    } else {
      return Observable.empty()
    }
  }

  private func updateExpiration(forKey key: String, interval: CacheTimeInterval) {
    let nextExpiration = Date().addingTimeInterval(TimeInterval(interval.rawValue))
    UserDefaults.standard.set(nextExpiration, forKey: key)
  }

  func connect(_ subject: ReplaySubject<E>) -> Observable<E> {
    return self.do(onNext: { value in
      subject.onNext(value)
    })
  }

  func connect<R>(_ subject: ReplaySubject<R>, transform: @escaping (E, R) -> R) -> Observable<E> {
    return self.do(onNext: { value in
      let dispose = subject.subscribe(onNext: { subjectValue in
        let newData = transform(value, subjectValue)
        subject.onNext(newData)
      })
      dispose.dispose()
    })
  }
}
