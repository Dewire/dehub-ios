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

  public init() {
    api = GistApi()
  }
}
