//
//  Services.swift
//  DeHub
//
//  Created by Kalle Lindström on 12/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

public struct Services {
  public let state: State
  public let networkInteractor: P_NetworkInteractor

  
  public init() {
    state = State()
    
    networkInteractor = NetworkInteractor(
      network: Network(
        session: NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()),
        requestHelper: RequestHelper()),
      state: state)
  }
}