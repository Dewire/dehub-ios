//
//  Common.swift
//  DeHub
//
//  Created by Kalle Lindström on 15/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
@testable import Model
@testable import Scene
import RxSwift

// MARK: Network

class MockResourceFactory: ResourceFactory {
  
  private var stubs = [String: RestResponse]()
  private var errorStubs = [String: Error]()
  
  func setMockResponse(path: String,
                       jsonFile: String,
                       contentType: String = "application/json",
                       headers: [String : String]? = [:],
                       statusCode: Int = 200) {
    
    let data = json(forFile: jsonFile)
    let res = HTTPURLResponse(
      url: url(forPath: path),
      statusCode: statusCode,
      httpVersion: "HTTP/1.1",
      headerFields: headers)!
    
    stubs[path] = RestResponse(response: res, data: data)
  }
  
  func setMockError(path: String, error: Error) {
    errorStubs[path] = error
  }
  
  init() {
    super.init(baseUrl: "mock")
  }
  
  override func resource<A>(_ path: String,
                            cacheInterval: CacheTimeInterval? = nil,
                            parse: @escaping ((RestResponse) throws -> A)) -> Resource<A> {
    
    let u = url(forPath: path)
    let policy = cachePolicy(forUrl: u, cacheInterval: cacheInterval)
    
    var res = Resource(url: url(forPath: path),
                    parse: parse,
                    httpMethod: "GET",
                    headers: standardHeaders,
                    timeout: defaultTimeout,
                    cachePolicy: policy,
                    body: nil,
                    _customResponse: nil)
    
    if let error = errorStubs[path] {
      res._customResponse = Observable.error(error).observeOn(MainScheduler.instance)
      return res
    }
    
    if let stub = stubs[path] {
      res._customResponse = Observable.just(stub).map(parse).observeOn(MainScheduler.instance)
    } else {
      print("no stub matching path: \(path))")
      res._customResponse = Observable.never().observeOn(MainScheduler.instance)
    }
    
    return res
  }
}

// MARK: Util

func json(forFile: String) -> Data {
    
    func filePath(_ file: String) -> String {
        return "json/\(file)"
    }
    
    let bundle = Bundle(for: SpyNavigation.self)
    let url = bundle.url(forResource: filePath(forFile), withExtension: nil)!
    
    return try! Data.init(contentsOf: url)
}

// MARK: Spies

class SpyNavigation: Navigation {
    
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

class SpyLoginScene: LoginScene {
    var called_createStage: Bool = false
    var called_login: Bool = false
    var called_logout: Bool = false
    
    override func createStage() -> UIViewController {
        called_createStage = true
        return super.createStage()
    }
    
    override func login() {
        called_login = true
    }
    
    override func logout() {
        called_logout = true
    }
}

class SpyLoginStage: LoginStage {
    
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
