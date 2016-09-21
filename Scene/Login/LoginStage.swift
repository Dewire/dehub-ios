//
//  LoginStage.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginStage : DirectedViewController<LoginDirector> {
  
  @IBOutlet weak var username: UITextField!
  @IBOutlet weak var password: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  
  static func create(_ directorFactory: @escaping (LoginStage) -> LoginDirector) -> LoginStage {
    let storyboard = UIStoryboard(name: "Login", bundle: Bundle(for: LoginScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! LoginStage
  }

  override func bind(director: LoginDirector) {
    observeEnableLoginButton(director)
    observeResetUi(director)
  }
  
  fileprivate func observeEnableLoginButton(_ director: LoginDirector) {
    director.enableLoginButton.asDriver().drive(loginButton.rx.enabled)
      .addDisposableTo(bag)
  }
  
  fileprivate func observeResetUi(_ director: LoginDirector) {
    director.resetUi.asDriver(onErrorJustReturn: ()).drive(onNext: { [unowned self] _ in
      print("reset")
      self.password.text = ""
      self.username.text = ""
      self.username.becomeFirstResponder()
    })
    .addDisposableTo(bag)
  }
}

extension LoginStage {

  struct Actions {
    let username: ControlProperty<String>
    let password: ControlProperty<String>
    let loginPressed: ControlEvent<Void>
  }

  var actions: Actions {
    return Actions(
      username: username.rx.text,
      password: password.rx.text,
      loginPressed: loginButton.rx.tap)
  }
}
