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

class LoginStage : DirectedViewController {
  
  @IBOutlet weak var username: UITextField!
  @IBOutlet weak var password: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  
  static func create() -> LoginStage {
    let storyboard = UIStoryboard(name: "Login", bundle: Bundle(for: LoginScene.self))
    let stage = storyboard.instantiateInitialViewController() as! LoginStage
    return stage
  }
  
  func resetUi() {
    self.password.text = ""
    self.username.text = ""
    self.username.becomeFirstResponder()
  }
  
  func enableLoginButton(enabled: Bool) {
    loginButton.isEnabled = enabled
  }
  
  struct Outputs {
    let username: ControlProperty<String?>
    let password: ControlProperty<String?>
    let loginPressed: ControlEvent<Void>
  }

  var outputs: Outputs {
    return Outputs(
      username: username.rx.text,
      password: password.rx.text,
      loginPressed: loginButton.rx.tap)
  }
}
