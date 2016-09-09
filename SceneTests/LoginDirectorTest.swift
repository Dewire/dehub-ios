//
//  LoginDirectorTest.swift
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

typealias LoginResult = () -> Observable<Void>

class SpyNetworkInteractor : P_NetworkInteractor {
  var loginWasCalled = false
  var loginResult: LoginResult!
    
  func login(username: String, password: String) -> Observable<Void> {
    loginWasCalled = true
    return loginResult()
  }
  
  func getUser() -> Observable<Void> {
    return Observable.just(())
  }
}

class LoginDirectorTests: XCTestCase {
  
  // MARK: Setup
  
  var usernameInput: BehaviorSubject<String>!
  var passwordInput: BehaviorSubject<String>!
  var loginButtonInput: BehaviorSubject<Void>!
  
  var interactor: SpyNetworkInteractor!
  var director: LoginDirector!
  
  override func setUp() {
    super.setUp()
    
    usernameInput = BehaviorSubject(value: "")
    passwordInput = BehaviorSubject(value: "")
    loginButtonInput = BehaviorSubject(value: Void())
    
    interactor = SpyNetworkInteractor()
    interactor.loginResult = { Observable.just(()) }
    
    director = LoginDirector(
      actions: mockActions(),
      networkInteractor: interactor)
  }
  
  func mockActions() -> LoginStage.Actions {
    return LoginStage.Actions(
      username: ControlProperty<String>(values: usernameInput, valueSink: AnyObserver { n in }),
      password: ControlProperty<String>(values: passwordInput, valueSink: AnyObserver { n in }),
      loginPressed: ControlEvent<Void>(events: loginButtonInput))
  }
  
  // MARK: Tests
  
  func testInitialState() {
    expect(self.director.enableLoginButton.value).to(beFalse())
  }
  
  func testLoginButtonEnabledWhenUsernameAndPasswordEntered() {
    usernameInput.onNext("username")
    passwordInput.onNext("password")
    expect(self.director.enableLoginButton.value).toEventually(beTrue())
  }
  
  func testLoginButtonDisableAfterPressedAndLoginSuccess() {
    var wasDisabled = false
    var wasEnabled = false
    
    let _ = director.enableLoginButton.asObservable().skip(1).subscribeNext() {
      if !$0 {
        wasDisabled = true
      } else {
        wasEnabled = true
      }
    }
    
    loginButtonInput.onNext(Void())
    expect(wasDisabled).toEventually(beTrue())
    expect(wasEnabled).toEventuallyNot(beTrue())
  }
    
  func testLoginButtonDisableAndEnabledAfterPressedAndLoginFailure() {
    interactor.loginResult = { Observable.error(NSURLError.Unknown) }
    
    var wasDisabled = false
    var wasEnabled = false
    
    let _ = director.enableLoginButton.asObservable().skip(1).subscribeNext() {
      if !$0 {
        wasDisabled = true
      } else {
        wasEnabled = true
      }
    }
    
    loginButtonInput.onNext(Void())
    expect(wasDisabled).toEventually(beTrue())
    expect(wasEnabled).toEventually(beTrue())
  }
  
  func testLoginCalledWhenLoginButtonPressed() {
    loginButtonInput.onNext(Void())
    expect(self.interactor.loginWasCalled).toEventually(beTrue())
  }
}





