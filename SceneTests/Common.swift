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
import Siesta


// MARK: Network


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


class SpyNavigation : Navigation {
    
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

class SpyLoginScene : LoginScene {
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
