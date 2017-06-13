//
//  EventChannel.swift
//  DeHub
//
//  Created by Kalle Lindström on 2017-05-31.
//  Copyright © 2017 Dewire. All rights reserved.
//

import Foundation
import RxSwift

enum Event {
  case showSpinner
  case hideSpinner
  case displayError(error: Error)
}

final class EventChannel {
  let events = PublishSubject<Event>()
}

protocol EventChannelProvider {
  var eventChannel: EventChannel { get }
}
