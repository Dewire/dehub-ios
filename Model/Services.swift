//
//  Services.swift
//  DeHub
//
//  Created by Kalle Lindström on 12/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

public class Services {
  
  public static let shared = { () -> Services in 
    let state = State()
    let api = GistApi(resourceFactory: ResourceFactory(baseUrl: "https://api.github.com"), state: state)
    return Services(api: api, state: state)
  }()

  public let api: GistApi
  public let state: State

  init(
    api: GistApi,
    state: State
  ) {
    self.api = api
    self.state = state
  }
}
