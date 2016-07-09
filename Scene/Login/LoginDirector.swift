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

  let logoutRequested = PublishSubject<Void>()
  let loginSuccessful = PublishSubject<Void>()
  let resetUi = PublishSubject<Void>()
  
  let loginButtonHidden = Variable<Bool>(true)
  let loginButtonEnabled = Variable<Bool>(true)
  let username = Variable<String>("")
  let password = Variable<String>("")

  init(actions: LoginStage.Actions, networkInteractor: P_NetworkInteractor) {
    self.networkInteractor = networkInteractor
    super.init()
    
    registerForLogoutNotification()
  	observePasswordUsername(actions.password, username: actions.username)
    observeLoginPressed(actions.loginPressed)
  }
  
  private func registerForLogoutNotification() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: #selector(logout), name:"Logout", object: nil)
  }
  
  @objc private func logout() {
    print("logout")
    logoutRequested.onNext()
    resetUi.onNext()
    loginButtonEnabled.value = true
    loginButtonHidden.value = true
    username.value = ""
    password.value = ""
  }
  
  private func observePasswordUsername(password: ControlProperty<String>,
                                       username: ControlProperty<String>) {
    
    username.bindTo(self.username).addDisposableTo(bag)
    password.bindTo(self.password).addDisposableTo(bag)

    Driver
      .combineLatest(password.asDriver(), username.asDriver()) {
        ($0, $1)
      }
      .map { userPass in
        userPass.0.isEmpty || userPass.1.isEmpty
      }
      .drive(loginButtonHidden)
      .addDisposableTo(bag)
  }
  
  private func observeLoginPressed(press: ControlEvent<Void>) {
    press.subscribeNext {
      self.loginButtonEnabled.value = false
      self.performLoginRequest()
    }
    .addDisposableTo(self.bag)
  }
  
  private func performLoginRequest() {
    self.networkInteractor.login(self.username.value, password: self.password.value).subscribe { event in
      switch event {
      case .Next:
        print("login ok")
        self.loginSuccessful.onNext()
      case .Error:
        print("login error")
        self.loginButtonEnabled.value = true
      default: break
      }
    }
    .addDisposableTo(self.bag)
  }
}








