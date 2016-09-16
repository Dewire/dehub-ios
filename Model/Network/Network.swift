//
//  Network.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Gloss

protocol P_Network {
  func setUsername(_ username: String, password: String)
  func tryLogin(_ username: String, password: String) -> Observable<(Data, HTTPURLResponse)>
  func getGists() -> Observable<[JSON]>
  func get(url: String) -> Observable<Data>
}

class Network : P_Network {
  
  fileprivate let urlSession: URLSession
  fileprivate let requests: RequestHelper
  
  init(session: URLSession, requestHelper: RequestHelper) {
    urlSession = session
    requests = requestHelper
  }
  
  func setUsername(_ username: String, password: String) {
    requests.setUsername(username, password: password)
  }
  
  func tryLogin(_ username: String, password: String) -> Observable<(Data, HTTPURLResponse)> {
    return urlSession.rx.response(
      requests.makeLoginRequest(username, password: password)
    )
    .observeOn(MainScheduler.instance)
  }

  func getGists() -> Observable<[JSON]> {
    return urlSession.JSON_decode(requests.GET("gists") as URLRequest)
  }
  
  func get(url: String) -> Observable<Data> {
    let req = requests.GET(url, relativePath: false) as URLRequest
    return urlSession.rx.data(req)
  }
}

extension URLSession {

  func JSON_decode<T>(_ req: URLRequest) -> Observable<T> {
    return rx.JSON(req).map() { json in
      if let json = json as? T {
        return json
      } else {
        throw URLError(.cannotDecodeContentData)
      }
      }
      .observeOn(MainScheduler.instance)
  }
}
