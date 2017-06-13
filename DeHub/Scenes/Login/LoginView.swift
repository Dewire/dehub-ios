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
import Model

class LoginView: View {
  
  @IBOutlet weak var username: UITextField!
  @IBOutlet weak var password: UITextField!
  @IBOutlet weak var loginButton: UIButton!

  private var hiddenBag: DisposeBag!
  
  override var getViewModel: ViewModel { return viewModel }
  private var viewModel: LoginViewModel!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = LoginViewModel(services: services)
  }

  open override func viewWillAppear(_ animated: Bool) {
    hiddenBag = DisposeBag()
    super.viewWillAppear(animated)
  }

  override func startObserving(bag: DisposeBag) {
    let viewModelOutputs = viewModel.observe(inputs: outputs, bag: bag)
    observeViewModelOutput(viewModelOutputs, bag: bag)
  }

  private func observeViewModelOutput(_ output: LoginViewModel.Outputs, bag: DisposeBag) {
    output.isLoginButtonEnabled.drive(loginButton.rx.isEnabled).disposed(by: bag)
    
    output.isLoggedIn.drive(onNext: { isLoggedIn in
      if isLoggedIn {
        self.performSegue(withIdentifier: "GISTS_SEGUE", sender: nil)
      }
    }).disposed(by: bag)

    output.logout.drive(onNext: {
      self.resetUi()
      self.dismiss(animated: true)
    }).disposed(by: hiddenBag)
  }

  func resetUi() {
   self.password.text = ""
    self.username.text = ""
    self.username.becomeFirstResponder()
  }
  
  func enableLoginButton(enabled: Bool) {
    loginButton.isEnabled = enabled
  }
  
  var outputs: LoginViewModel.Inputs {
    return LoginViewModel.Inputs(
      username: username.rx.text,
      password: password.rx.text,
      loginPressed: loginButton.rx.tap)
  }
}
