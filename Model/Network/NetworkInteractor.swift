//
//  NetworkInteractor.swift
//  DeHub
//
//  Created by Kalle Lindström on 11/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import Gloss

public enum RequestOption {
  case noTrack
}

public typealias RequestOptions = [RequestOption]

public protocol P_NetworkInteractor {
  var requestsInProgress: Observable<Int> { get }
  func login(username: String, password: String, options: RequestOptions) -> Observable<Void>
  func loadGists(options: RequestOptions)                                 -> Observable<Void>
  func get(url: String, options: RequestOptions)                          -> Observable<Data>
  func create(gist: CreateGistEntity, options: RequestOptions)            -> Observable<Data>
}

fileprivate let reqsInProgress = Variable<Int>(0)

open class NetworkInteractor : P_NetworkInteractor {
  
  public var requestsInProgress: Observable<Int> { return reqsInProgress.asObservable() }

  let network: P_Network
  let state: State
  
  init(network: P_Network, state: State) {
    self.network = network
    self.state = state
  }
  
  open func login(username: String, password: String, options: RequestOptions) -> Observable<Void> {
    
    handle(options)
    return network.tryLogin(username, password: password)
      .handle(options)
      .map() { data, response in
        if response.statusCode != 200 {
          throw URLError(.userAuthenticationRequired)
        }
        self.network.setUsername(username, password: password)
        return ()
      }
  }
  
  open func loadGists(options: RequestOptions) -> Observable<Void> {
    
    handle(options)
    return network.getGists()
      .handle(options)
      .map() { json in
      let gists = [GistEntity].fromJSONArray(json)
      guard gists?.count == json.count else { throw URLError(.cannotDecodeContentData) }
      
      self.state.gists.value = gists
      return ()
    }
  }
  
  open func get(url: String, options: RequestOptions) -> Observable<Data> {
    
    handle(options)
    return network.get(url: url).handle(options)
  }
  
  open func create(gist: CreateGistEntity, options: RequestOptions) -> Observable<Data> {
    handle(options)
    return network.create(gist: gist).handle(options)
  }
  
  private func handle(_ options: RequestOptions) {
    if !options.contains(.noTrack) {
      reqsInProgress.value += 1
    }
  }
}

fileprivate extension Observable {
  
  func handle(_ options: RequestOptions) -> Observable {
    return self.do(
      onError: { _ throws in
        self.checkDecreaseReqs(options)
      },
      onCompleted: { _ throws in
        self.checkDecreaseReqs(options)
      }
    )
  }
  
  private func checkDecreaseReqs(_ options: RequestOptions) {
    if !options.contains(.noTrack) {
      reqsInProgress.value -= 1
    }
  }
}


