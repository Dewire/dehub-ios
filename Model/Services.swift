//
//  Services.swift
//  DeHub
//
//  Created by Kalle Lindström on 12/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation

public struct Services {
  public let api: GistApi
  public let state: State

  public init() {
    state = State()
    api = GistApi(restService: RestService(baseUrl: "https://api.github.com"), state: state)
  }
}
