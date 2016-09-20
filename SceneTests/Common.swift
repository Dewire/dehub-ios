//
//  Common.swift
//  DeHub
//
//  Created by Kalle Lindström on 15/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import Model
@testable import Scene
import RxSwift

class NopNetworkInteractor : P_NetworkInteractor {
  
  var requestsInProgress: Observable<Int> {
    return Observable.never()
  }
  
  func login(username: String, password: String, options: RequestOptions) -> Observable<Void> {
    return Observable.never()
  }
  
  func loadGists(options: RequestOptions) -> Observable<Void> {
    return Observable.never()
  }
  
  func get(url: String, options: RequestOptions) -> Observable<Data> {
    return Observable.never()
  }
  
  func create(gist: CreateGistEntity, options: RequestOptions) -> Observable<Data> {
    return Observable.never()
  }
}

class SpyNavigation : Navigation {
  
  var presentedController: UIViewController?
  var pushedController: UIViewController?
  var dismissCalled = false
  var poppedController = false
  
  func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
    presentedController = viewControllerToPresent
  }
  
  func dismiss(animated flag: Bool, completion: (() -> Void)?) {
    dismissCalled = true
  }
  
  func pushController(_ viewController: UIViewController, animated: Bool) {
    pushedController = viewController
  }
  
  func popController(animated: Bool) {
    poppedController = true
  }
}
