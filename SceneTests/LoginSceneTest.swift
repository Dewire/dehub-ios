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
  var scene: LoginScene!
  
  override func setUp() {
    super.setUp()
    
    scene = LoginScene(services: Services())
    spyNavigation = SpyNavigation()
    scene.navigation = spyNavigation
  }
  
  
  // MARK: Tests
  
  
  func testPresentsControllerOnSuccessfulLogin() {
    scene.login()
    expect(self.spyNavigation.presentedController).toEventuallyNot(beNil())
  }
  
  func testDismissesControllerOnLogout() {
    scene.logout()
    expect(self.spyNavigation.dismissCalled).toEventually(beTrue())
  }
  
  //func testStateIsResetOnLogout() {
    // TODO
  //}
}






