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

  private func registerForLogoutNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: #selector(logout), name:"Logout", object: nil)
  }

  private func observeActions(actions: LoginStage.Actions) {
    let userPass = Driver.combineLatest(actions.username.asDriver(), actions.password.asDriver()) {
      ($0, $1)
    }

    observeUsernamePassword(userPass)
    observeLoginPressed(userPass, loginPressed: actions.loginPressed)
  }

  private func observeUsernamePassword(userPass: Driver<(String, String)>) {
    userPass.map { userPass in
      return !userPass.0.isEmpty && !userPass.1.isEmpty
    }
    .drive(enableLoginButton)
    .addDisposableTo(bag)
  }

  private func observeLoginPressed(userPass: Driver<(String, String)>, loginPressed: ControlEvent<Void>) {
    loginPressed.asDriver()
      .withLatestFrom(userPass) { $1 }
      .driveNext { userPass in
        self.enableLoginButton.value = false
        self.performLoginRequest(userPass.0, password: userPass.1)
      }
      .addDisposableTo(bag)
  }

  @objc private func logout() {
    print("logout")
    resetUi.onNext()
    logoutRequested.onNext()
    enableLoginButton.value = false
  }

  private func performLoginRequest(username: String, password: String) {
    self.networkInteractor.login(username, password: password).subscribe { event in
      switch event {
      case .Next:
        print("login ok")
        self.loginSuccessful.onNext()
      case .Error:
        print("login error")
        self.enableLoginButton.value = true
      default: break
      }
    }
    .addDisposableTo(self.bag)
  }
}
