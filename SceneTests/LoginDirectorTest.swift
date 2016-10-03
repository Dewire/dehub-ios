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
import Nimble

typealias LoginResult = () -> Observable<Void>

class SpyLoginStage : LoginStage {
  
  let o: LoginStage.Outputs
  
  init(outputs: LoginStage.Outputs) {
    o = outputs
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var resetUiCalled: Bool = false
  override func resetUi() {
    resetUiCalled = true
  }
  
  var enableLoginButtonValue: Bool?
  override func enableLoginButton(enabled: Bool) {
    enableLoginButtonValue = enabled
  }
  
  override var outputs: Outputs { return o }
}


class LoginDirectorTests: XCTestCase {
  
  
  // MARK: Setup
  
  var usernameInput: BehaviorSubject<String>!
  var passwordInput: BehaviorSubject<String>!
  var loginButtonInput: BehaviorSubject<Void>!
  
  var navigation: SpyNavigation!
  var stage: SpyLoginStage!
  var director: LoginDirector!
  
  override func setUp() {
    super.setUp()
    
    usernameInput = BehaviorSubject(value: "")
    passwordInput = BehaviorSubject(value: "")
    loginButtonInput = BehaviorSubject(value: Void())
    
    let api = GistApi()
    
    let scene = LoginScene(services: Services())
    scene.navigation = navigation
    director = LoginDirector(
      scene: scene,
      api: api)
    
    stage = SpyLoginStage(outputs: mockOutputs())
    director.stage = stage
  }
  
  func mockOutputs() -> LoginStage.Outputs {
    return LoginStage.Outputs(
      username: ControlProperty<String>(values: usernameInput, valueSink: AnyObserver { n in }),
      password: ControlProperty<String>(values: passwordInput, valueSink: AnyObserver { n in }),
      loginPressed: ControlEvent<Void>(events: loginButtonInput))
  }
  
  
  // MARK: Tests
  
  func testLoginButtonDisabledWhenUsernameAndPasswordNotEntered() {
    usernameInput.onNext("")
    passwordInput.onNext("")
    
    expect(self.stage.enableLoginButtonValue).toEventually(beFalse())
  }
  
  func testLoginButtonEnabledWhenUsernameAndPasswordEntered() {
    usernameInput.onNext("username")
    passwordInput.onNext("password")
    
    expect(self.stage.enableLoginButtonValue).toEventually(beTrue())
  }
 
  /* TODO: fix these
  func testLoginButtonDisableAfterPressedAndLoginSuccess() {
    loginButtonInput.onNext(Void())
    expect(self.stage.enableLoginButtonValue).toEventually(beFalse())
  }
  
  func testLoginButtonEnabledAfterPressedAndLoginFailure() {
    interactor.loginResult = { Observable.error(URLError(.unknown)) }
    
    loginButtonInput.onNext(Void())
    expect(self.stage.enableLoginButtonValue).toEventually(beTrue())
  }
  
  func testLoginCalledWhenLoginButtonPressed() {
    loginButtonInput.onNext(Void())
    expect(self.interactor.loginWasCalled).toEventually(beTrue())
  }
 */
}





