//
//  LoginDirector.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class LoginDirector : BaseDirector {
  
  let networkInteractor: P_NetworkInteractor

  // Scene outputs
  let loginSuccessful = PublishSubject<Void>()
  let logoutRequested = PublishSubject<Void>()

  // Stage outputs
  let enableLoginButton = Variable<Bool>(false)
  let resetUi = PublishSubject<Void>()

  init(actions: LoginStage.Actions, networkInteractor: P_NetworkInteractor) {
    self.networkInteractor = networkInteractor
    super.init()

    registerForLogoutNotification()
    observeActions(actions)
  }

  fileprivate func registerForLogoutNotification() {
    NotificationCenter.default.addObserver(self,
      selector: #selector(logout), name:NSNotification.Name(rawValue: "Logout"), object: nil)
  }

  fileprivate func observeActions(_ actions: LoginStage.Actions) {
    let userPass = Driver.combineLatest(actions.username.asDriver(), actions.password.asDriver()) {
      ($0, $1)
    }

    observeUsernamePassword(userPass)
    observeLoginPressed(userPass, loginPressed: actions.loginPressed)
  }

  fileprivate func observeUsernamePassword(_ userPass: Driver<(String, String)>) {
    userPass.map { userPass in
      return !userPass.0.isEmpty && !userPass.1.isEmpty
    }
    .drive(enableLoginButton)
    .addDisposableTo(bag)
  }

  fileprivate func observeLoginPressed(_ userPass: Driver<(String, String)>, loginPressed: ControlEvent<Void>) {
    loginPressed.asDriver()
      .withLatestFrom(userPass) { $1 }
      .drive(onNext: { userPass in
        self.enableLoginButton.value = false
        self.performLoginRequest(userPass.0, password: userPass.1)
      })
      .addDisposableTo(bag)
  }

  @objc fileprivate func logout() {
    print("logout")
    resetUi.onNext()
    logoutRequested.onNext()
    enableLoginButton.value = false
  }

  fileprivate func performLoginRequest(_ username: String, password: String) {
    self.networkInteractor.login(username: username, password: password).subscribe { event in
      if event.error != nil {
        print("login error")
        self.enableLoginButton.value = true
      }
      else {
        print("login ok")
        self.loginSuccessful.onNext()
      }
    }
    .addDisposableTo(self.bag)
  }
}
