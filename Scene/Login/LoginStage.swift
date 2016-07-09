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
    observeLoginButtonHidden(director)
    observeLoginButtonEnabled(director)
    observeResetUi(director)
  }
  
  private func observeLoginButtonHidden(director: LoginDirector) {
    director.loginButtonHidden.asDriver()
      .distinctUntilChanged()
      .driveNext { [unowned self] hidden in
        if !hidden { self.loginButton.hidden = false }
        self.animateLoginButtonHidden(hidden)
      }
      .addDisposableTo(bag)
  }
  
  private func animateLoginButtonHidden(hidden: Bool) {
    self.loginButton.alpha = hidden ? 1 : 0
    
    UIView.animateWithDuration(0.8) {
      self.loginButton.alpha = hidden ? 0 : 1
    }
  }
  
  private func observeLoginButtonEnabled(director: LoginDirector) {
    director.loginButtonEnabled.asDriver().drive(loginButton.rx_enabled)
      .addDisposableTo(bag)
  }
  
  private func observeResetUi(director: LoginDirector) {
    director.resetUi.subscribeNext { [unowned self] _ in
      print(NSThread.isMainThread())
      self.username.text = ""
      self.password.text = ""
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

