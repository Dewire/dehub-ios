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
import Quick
import Nimble

class LoginSceneTests: QuickSpec {
  override func spec() {
    
    // MARK: Setup
    
    var spyNavigation: SpyNavigation!
    var scene: LoginScene!
    
    describe("the login scene") {
      
      beforeEach {
        scene = LoginScene(services: Services())
        spyNavigation = SpyNavigation()
        scene.navigation = spyNavigation
      }
      
      // MARK: Tests
      
      it("presents the controller on a successful login") {
        
        scene.login()
        
        expect(spyNavigation.presentedController).toEventuallyNot(beNil())
      }
      
      it("dismisses a controller on logout") {
        
        scene.logout()
        
        expect(spyNavigation.dismissCalled).toEventually(beTrue())
      }
    }
  }
}

