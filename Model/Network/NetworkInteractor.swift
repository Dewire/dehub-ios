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

public protocol P_NetworkInteractor {
  func login(username: String, password: String) -> Observable<Void>
  func loadGists() -> Observable<Void>
  func get(url: String) -> Observable<Data>
}

open class NetworkInteractor : P_NetworkInteractor {
  let network: P_Network
  let state: State
  
  init(network: P_Network, state: State) {
    self.network = network
    self.state = state
  }
  
  open func login(username: String, password: String) -> Observable<Void> {
    return network.tryLogin(username, password: password)
      .map() { data, response in
        if response.statusCode != 200 {
          throw URLError(.userAuthenticationRequired)
        }
        self.network.setUsername(username, password: password)
        return ()
      }
  }
  
  open func loadGists() -> Observable<Void> {
    return network.getGists().map() { json in
      let gists = [GistEntity].fromJSONArray(json)
      guard gists?.count == json.count else { throw URLError(.cannotDecodeContentData) }
      
      self.state.gists.value = gists
      return ()
    }
  }
  
  open func get(url: String) -> Observable<Data> {
    return network.get(url: url)
  }
}

