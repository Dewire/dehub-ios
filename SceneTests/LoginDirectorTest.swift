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
import Siesta

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

class MockProvider: NetworkingProvider {
  
  var stubs = [String: ResponseStub]()
  
  var defaultHeaders = [String:String]()
  
  func startRequest(
    _ request: URLRequest,
    completion: @escaping RequestNetworkingCompletionCallback) -> RequestNetworking {
    
    guard let stub = stub(forRequest: request) else {
      puts("no stub matching url: \(request.url?.absoluteString)")
      return RequestStub()
    }
    
    var headers = defaultHeaders
    headers["Content-Type"] = stub.contentType
    
    let response = HTTPURLResponse(
      url: request.url!,
      statusCode: stub.error == nil ? 200 : 500,
      httpVersion: "HTTP/1.1",
      headerFields: headers)
    
    completion(response, stub.data, stub.error)
    
    return RequestStub()
  }
  
  private func stub(forRequest req: URLRequest) -> ResponseStub? {
    for key in stubs.keys {
      if req.url!.absoluteString.contains(key) {
        return stubs[key]
      }
    }
    return nil
  }
  
}

struct ResponseStub {
  let contentType: String
  let data: Data
  let error: Error?
  
  init(contentType: String = "application/octet-stream", data: Data, error: Error? = nil) {
    self.contentType = contentType
    self.error = error
    self.data = data
  }
}
  
struct RequestStub: RequestNetworking {
    
  func cancel() { }
    
  /// Returns raw data used for progress calculation.
  var transferMetrics: RequestTransferMetrics {
      
    return RequestTransferMetrics(
      requestBytesSent: 0,
      requestBytesTotal: nil,
      responseBytesReceived: 0,
      responseBytesTotal: nil)
  }
}

class LoginDirectorTests: XCTestCase {
  
  
  // MARK: Setup
  
  var usernameInput: BehaviorSubject<String>!
  var passwordInput: BehaviorSubject<String>!
  var loginButtonInput: BehaviorSubject<Void>!
  
  var mockProvider: MockProvider!
  var navigation: SpyNavigation!
  var stage: SpyLoginStage!
  var scene: SpyLoginScene!
  var director: LoginDirector!
  
  override func setUp() {
    super.setUp()
    
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
 
  func testLoginButtonDisableAfterPressed() {
    usernameInput.onNext("username")
    passwordInput.onNext("password")
    
    
    loginButtonInput.onNext(Void())
    expect(self.stage.enableLoginButtonValue).toEventually(beFalse())
  }
  
  func testLoginButtonEnabledAfterPressedAndLoginFailure() {
    usernameInput.onNext("username")
    passwordInput.onNext("password")
    
    mockProvider.stubs["/gists"] = ResponseStub(data: json(forFile: "gists"),
                                                error: URLError(.unknown))
    
    loginButtonInput.onNext(Void())
    expect(self.stage.enableLoginButtonValue).toEventually(beTrue())
  }
 
  func testLoginCalledWhenLoginButtonPressed() {
    mockProvider.stubs["/gists"] = ResponseStub(contentType: "application/json",
                                                data: json(forFile: "gists"),
                                                error: nil)
    
    
    loginButtonInput.onNext(Void())
    expect(self.scene.called_login).toEventually(beTrue())
  }
}





