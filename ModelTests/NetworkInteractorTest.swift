//
//  NetworkInteractorTest.swift
//  ModelTests
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import XCTest
@testable import Model
import RxSwift
import RxCocoa
import Nimble
import Gloss

class MockNetwork : P_Network {
  
  init() {}
  
  var userFactory: (() -> Observable<JSON>)! = nil
  
  func setUsername(username: String, password: String) { }
  
  func tryLogin(username: String, password: String) -> Observable<(NSData, NSHTTPURLResponse)> {
    let data = NSData()
    let res = NSHTTPURLResponse()
    return Observable.just((data, res))
  }
  
  func getUser() -> Observable<JSON> {
    return userFactory()
  }
}

class NetworkInteractorTest: XCTestCase {
  
  func testGetUserFail() {
    let state = State()
    let network = MockNetwork()
    
    network.userFactory = { Observable.just(["test" : 2]) }
    
    let interactor = NetworkInteractor(network: network, state: state)
    
    var error: ErrorType?
    let _ = interactor.getUser().subscribe() { event in
      if case .Error(let e) = event {
        error = e
      }
    }
    
    expect(error).toEventuallyNot(beNil())
    expect(state.user.value).toEventually(beNil())
  }
  
  func testGetUserOk() {
    let state = State()
    let network = MockNetwork()
    
    network.userFactory = { Observable.just([
        "login": "octocat",
        "id": 1,
        "avatar_url": "https://github.com/images/error/octocat_happy.gif"
    ])}
    
    let interactor = NetworkInteractor(network: network, state: state)
    let _ = interactor.getUser().subscribeNext() { _ in }

    expect(state.user.value).toEventuallyNot(beNil())
    expect(state.user.value?.username).toEventually(equal("octocat"))
  }
}














