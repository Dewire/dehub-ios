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

enum Progress<T> {
  case notStarted
  case inProgress
  case completed(T)
}

public class LoginViewModel: ViewModel {

  let api: GistApi

  init(services: Services) {
    self.api = services.api
  }

  struct Inputs {
    let username: ControlProperty<String?>
    let password: ControlProperty<String?>
    let loginPressed: ControlEvent<Void>
  }

  struct Outputs {
    let isLoginButtonEnabled: Driver<Bool>
    let isLoggedIn: Driver<Bool>
    let logout: Driver<Void>
  }

  func observe(inputs: Inputs, bag: DisposeBag) -> Outputs {
  
    let userPass = Driver.combineLatest(
        inputs.username.asDriver().withoutNils(),
        inputs.password.asDriver().withoutNils()) {
      ($0, $1)
    }

    let hasText = userPass.map { userPass in
      return !userPass.0.isEmpty && !userPass.1.isEmpty
    }

    let loginState = inputs.loginPressed.asDriver().triggeredProgress(fromSource: userPass) { userPass in
      self.api.login(username: userPass.0, password: userPass.1)
        .spin().error()
    }

    return Outputs(
      isLoginButtonEnabled: loginButtonEnabledDriver(hasText: hasText, loginState: loginState),
      isLoggedIn: isLoggedInDriver(loginState: loginState),
      logout: logoutEventDriver()
    )
  }

  private func isLoggedInDriver(loginState: Driver<Progress<Bool>>) -> Driver<Bool> {
    return loginState.map { state -> Bool in
      if case let .completed(ok) = state {
        return ok
      } else {
        return false
      }
    }.distinctUntilChanged()
  }

  private func loginButtonEnabledDriver(hasText: Driver<Bool>, loginState: Driver<Progress<Bool>>) -> Driver<Bool> {
    return Driver.combineLatest(hasText, loginState) { hasText, loginState -> Bool in
      switch loginState {
      case .notStarted: return hasText
      case .inProgress: return false
      case .completed(let ok): return !ok && hasText
      }
    }.distinctUntilChanged()
  }

  private func logoutEventDriver() -> Driver<Void> {
    return NotificationCenter.default.rx.notification(Notification.Name("Logout"))
      .do(onNext: { _ in
        self.api.logout()
      })
      .map { _ in () }
      .asDriver(onErrorJustReturn: ())
  }
}
