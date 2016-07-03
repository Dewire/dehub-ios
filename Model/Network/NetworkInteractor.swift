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
  func getUser() -> Observable<Void>
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
  
  public func getUser() -> Observable<Void> {
    return network.getUser().map() { json in
      if let u = UserEntity(json: json) {
        self.state.user.value = u
        return ()
      } else {
        throw NSURLError.CannotDecodeContentData
      }
    }
  }
}

