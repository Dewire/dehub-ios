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

class LoginDirector: BaseDirector<LoginScene, LoginStage> {
  
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
    let userPass = Observable.combineLatest(outputs.username.asObservable().withoutNils(),
                                            outputs.password.asObservable().withoutNils()) {
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
        self.performLoginRequest(username: userPass.0, password: userPass.1)
      })
      .addDisposableTo(bag)
  }
  
  private func performLoginRequest(username: String, password: String) {
    api.login(username: username, password: password)
      .spin(self).error(self)
      .subscribe(onNext: { [weak self] loggedIn in
        if loggedIn {
          self?.scene.login()
        } else {
          print("Wrong credentials")
          self?.stage.enableLoginButton(enabled: true)
        }
        }, onError: { [weak self] _ in
          self?.stage.enableLoginButton(enabled: true)
      })
      .addDisposableTo(bag)
  }
  
  @objc private func logout() {
    stage.resetUi()
    stage.enableLoginButton(enabled: false)
    scene.logout()
  }
}

