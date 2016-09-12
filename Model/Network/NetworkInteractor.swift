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
}

public class NetworkInteractor : P_NetworkInteractor {
  let network: P_Network
  let state: State
  
  init(network: P_Network, state: State) {
    self.network = network
    self.state = state
  }
  
  public func login(username: String, password: String) -> Observable<Void> {
    return network.tryLogin(username, password: password)
      .map() { data, response in
        if response.statusCode != 200 {
          throw NSURLError.UserAuthenticationRequired
        }
        self.network.setUsername(username, password: password)
        return ()
      }
  }
  
  public func loadGists() -> Observable<Void> {
    return network.getGists().map() { json in
      let gists = [GistEntity].fromJSONArray(json)
      guard gists.count == json.count else { throw NSURLError.CannotDecodeContentData }
      
      self.state.gists.value = gists
      return ()
    }
  }
}

