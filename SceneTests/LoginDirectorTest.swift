//
//  LoginDirectorTest.swift
//  SceneTests
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import XCTest
@testable import Scene
@testable import Model
import RxSwift
import RxCocoa
import Siesta
import Quick
import Nimble

typealias LoginResult = () -> Observable<Void>

class LoginDirectorTests: QuickSpec {
  override func spec() {
    
    // MARK: Setup
    
    var usernameInput: BehaviorSubject<String>!
    var passwordInput: BehaviorSubject<String>!
    var loginButtonInput: BehaviorSubject<Void>!
  
    var mockProvider: MockProvider!
    var navigation: SpyNavigation!
    var stage: SpyLoginStage!
    var scene: SpyLoginScene!
    var director: LoginDirector!
    
    describe("the login director") {
      
      beforeEach {
        usernameInput = BehaviorSubject(value: "")
        passwordInput = BehaviorSubject(value: "")
        loginButtonInput = BehaviorSubject(value: Void())
        
        mockProvider = MockProvider()
        let api = GistApi(networkProvider: mockProvider)
        
        navigation = SpyNavigation()
        
        scene = SpyLoginScene(services: Services())
        scene.navigation = navigation
        director = LoginDirector(
          scene: scene,
          api: api)
        
        stage = SpyLoginStage(outputs: LoginStage.Outputs(
          username: ControlProperty<String>(values: usernameInput.skip(1), valueSink: AnyObserver { n in }),
          password: ControlProperty<String>(values: passwordInput.skip(1), valueSink: AnyObserver { n in }),
          loginPressed: ControlEvent<Void>(events: loginButtonInput.skip(1))))
          
        director.stage = stage
      }
      
      // MARK: Tests
      
      it("disables the login button when username and password are not entered") {
        
        usernameInput.onNext("")
        passwordInput.onNext("")
        
        expect(stage.enableLoginButtonValue).toEventually(beFalse())
      }
      
      it("enables the login button when username and password are entered") {
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        
        expect(stage.enableLoginButtonValue).toEventually(beTrue())
      }
      
      it("disables the login button after it is tapped") {
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(())
        
        expect(stage.enableLoginButtonValue).toEventually(beFalse())
      }
      
      it("enables the login button after it is tapped and the login request fails") {
        
        mockProvider.stubs["/gists"] = ResponseStub(data: json(forFile: "gists"),
                                                    error: URLError(.unknown))
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(Void())
        
        expect(stage.enableLoginButtonValue).toEventually(beTrue())
      }
      
      it("calls login on the scene after the login button is tapped and the login request succeeds")  {
        
        mockProvider.stubs["/gists"] = ResponseStub(contentType: "application/json",
                                                    data: json(forFile: "gists"),
                                                    error: nil)
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(Void())
        
        expect(scene.called_login).toEventually(beTrue())
      }
    }
  }
}


