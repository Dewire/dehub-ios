//
//  LoginDirectorTest.swift
//  DeHubTests
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//
// swiftlint:disable function_body_length

import XCTest
@testable import DeHub
@testable import Model
import RxSwift
import RxCocoa
import RxBlocking
import Quick
import Nimble

typealias LoginResult = () -> Observable<Void>

class LoginViewModelTests: QuickSpec {
  override func spec() {
    
    // MARK: Setup
    
    var usernameInput: BehaviorSubject<String?>!
    var passwordInput: BehaviorSubject<String?>!
    var loginButtonInput: BehaviorSubject<Void>!
  
    var resourceFactory: MockResourceFactory!
    var viewModel: LoginViewModel!
    var outputs: LoginViewModel.Outputs!
    
    describe("the login view model") {
      
      beforeEach {
        usernameInput = BehaviorSubject(value: "")
        passwordInput = BehaviorSubject(value: "")
        loginButtonInput = BehaviorSubject(value: Void())
        
        let state = State()
        resourceFactory = MockResourceFactory()
        let api = GistApi(resourceFactory: resourceFactory, state: state)
        
        let services = Services(api: api, state: state)
        
        viewModel = LoginViewModel(services: services)
        
        outputs = viewModel.observe(inputs: LoginViewModel.Inputs(
          username: ControlProperty<String?>(values: usernameInput, valueSink: AnyObserver { _ in }),
          password: ControlProperty<String?>(values: passwordInput, valueSink: AnyObserver { _ in }),
          loginPressed: ControlEvent<Void>(events: loginButtonInput)), bag: DisposeBag())
      }
      
      // MARK: Tests
      
      it("disables the login button when username and password are not entered") {
        
        usernameInput.onNext("")
        passwordInput.onNext("")
        
        try! expect(outputs.isLoginButtonEnabled.toBlocking().first()).to(beFalse())
      }
      
      it("enables the login button when username and password are entered") {
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        
        try! expect(outputs.isLoginButtonEnabled.toBlocking().first()).to(beTrue())
      }
      
      it("disables the login button after it is tapped") {
        
        resourceFactory.setMockResponse(path: "gists", jsonFile: "gists")
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(())
        
        try! expect(outputs.isLoginButtonEnabled.asObservable().take(2).toBlocking().last()).to(beFalse())
      }
      
      it("it enabled the login button again on a failed login") {
        
        resourceFactory.setMockError(path: "gists", error: AnyError())
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(())
        
        try! expect(outputs.isLoginButtonEnabled.asObservable().take(3).toBlocking().last()).to(beTrue())
      }
      
      it("signals that the login is successful") {
        
        resourceFactory.setMockResponse(path: "gists", jsonFile: "gists")
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(Void())
        
        try! expect(outputs.isLoggedIn.asObservable().take(2).toBlocking().last()).to(beTrue())
      }
      
      it("signals that the login failed") {
        
        resourceFactory.setMockError(path: "gists", error: AnyError())
        
        usernameInput.onNext("username")
        passwordInput.onNext("password")
        loginButtonInput.onNext(Void())
        
        try! expect(outputs.isLoggedIn.asObservable().take(1).toBlocking().last()).to(beFalse())
      }
    }
  }
}


