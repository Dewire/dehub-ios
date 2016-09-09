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
  
  static func create(directorFactory: LoginStage -> LoginDirector) -> LoginStage {
    let storyboard = UIStoryboard(name: "Login", bundle: NSBundle(forClass: LoginScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! LoginStage
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func bindDirector(director: LoginDirector) {
    observeEnableLoginButton(director)
    observeResetUi(director)
  }
  
  private func observeEnableLoginButton(director: LoginDirector) {
    director.enableLoginButton.asDriver().drive(loginButton.rx_enabled)
      .addDisposableTo(bag)
  }
  
  private func observeResetUi(director: LoginDirector) {
    director.resetUi.subscribeNext { [unowned self] _ in
      self.password.text = ""
      self.username.text = ""
      self.username.becomeFirstResponder()
    }
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
      username: username.rx_text,
      password: password.rx_text,
      loginPressed: loginButton.rx_tap)
  }
}

