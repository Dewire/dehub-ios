//
//  LoginSceneTest.swift
//  SceneTests
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import XCTest
@testable import Scene
import Model
import RxSwift
import RxCocoa
import Nimble


class LoginSceneTests: XCTestCase {
  
  // MARK: Setup
  
  
  var spyNavigation: SpyNavigation!
  var director: LoginDirector!
  var scene: LoginScene!
  
  override func setUp() {
    super.setUp()
    
    scene = LoginScene(services: Services())
    spyNavigation = SpyNavigation()
    scene.navigation = spyNavigation
    
    director = LoginDirector(
      actions: mockActions(),
      networkInteractor: NopNetworkInteractor())
    
    scene.observeDirector(director)
    
  }
  
  func mockActions() -> LoginStage.Actions {
    return LoginStage.Actions(
      username: ControlProperty<String>(values: Observable.never(), valueSink: AnyObserver { n in }),
      password: ControlProperty<String>(values: Observable.never(), valueSink: AnyObserver { n in }),
      loginPressed: ControlEvent<Void>(events: Observable.never()))
  }
  
  // MARK: Tests
  
  
  func testPresentsControllerOnSuccessfulLogin() {
    director.loginSuccessful.onNext(())
    expect(self.spyNavigation.presentedController).toEventuallyNot(beNil())
  }
  
  func testDismissesControllerOnLogout() {
    director.logoutRequested.onNext(())
    expect(self.spyNavigation.dismissCalled).toEventually(beTrue())
  }
  
  //func testStateIsResetOnLogout() {
    // TODO
  //}
}






