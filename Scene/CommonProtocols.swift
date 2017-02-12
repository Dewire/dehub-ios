//
//  CommonProtocols.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-01-22.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation

/**
 Something that can display a formatted error message to the user.
 */
protocol ErrorDisplayer {
  func display(error: Error)
}

/**
 Something that can show/hide a "spinner" (loading indicator) to the user,
 indicating that a load (e.g. network request) is in progress.
 */
protocol SpinnerDisplayer {
  func showSpinner()
  func hideSpinner()
}
