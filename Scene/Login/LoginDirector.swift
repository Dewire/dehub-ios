//
//  LoginDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Model

class LoginDirector : BaseDirector<LoginScene, LoginStage> {
  
  let api: GistApi

  init(scene: LoginScene, api: GistApi) {
    self.api = api
    super.init(scene: scene)
  }
  
  override func stageDidLoad(stage: LoginStage) {
    registerForLogoutNotification()
    observeOutputs(outputs: stage.outputs)
  }

  private func registerForLogoutNotification() {
    NotificationCenter.default.addObserver(self,
      selector: #selector(logout), name: NSNotification.Name(rawValue: "Logout"), object: nil)
  }

  private func observeOutputs(outputs: LoginStage.Outputs) {
    let userPass = Observable.combineLatest(outputs.username.asObservable(),
                                            outputs.password.asObservable()) {
      ($0, $1)
    }

    observeUsernamePassword(userPass)
    observeLoginPressed(userPass, loginPressed: outputs.loginPressed)
  }

  private func observeUsernamePassword(_ userPass: Observable<(String, String)>) {
    userPass.map { userPass in
      return !userPass.0.isEmpty && !userPass.1.isEmpty
    }
    .subscribe(onNext: { enabled in
      self.stage.enableLoginButton(enabled: enabled)
    })
    .addDisposableTo(bag)
  }
  
  private func observeLoginPressed(_ userPass: Observable<(String, String)>, loginPressed: ControlEvent<Void>) {
    loginPressed.asObservable()
      .withLatestFrom(userPass) { $1 }
      .subscribe(onNext: { userPass in
        self.stage.enableLoginButton(enabled: false)
        self.performLoginRequest(userPass.0, password: userPass.1)
      })
      .addDisposableTo(bag)
  }
  
  @objc private func logout() {
    print("logout")
    stage.resetUi()
    stage.enableLoginButton(enabled: false)
    scene.logout()
  }

  private func performLoginRequest(_ username: String, password: String) {
    
    api.login(username: username, password: password)
      .onFailure { [weak self] e in
        print("login error: \(e)")
        self?.stage.enableLoginButton(enabled: true)
      }
      .onSuccess { [weak self] s in
        print("login ok")
        self?.scene.login()
      }
  }
}
