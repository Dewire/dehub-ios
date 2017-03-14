import UIKit
import RxSwift

typealias Closure = () -> Void

open class Stage: UIViewController {
  
  let bag = DisposeBag()
  
  var directorRef: DirectorType?
  
  var afterLoad: Closure?
  
  let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    spinner.color = UIColor.red
    return spinner
  }()
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupSpinner()
    afterLoad?()
    afterLoad = nil
  }
  
  private func setupSpinner() {
    spinner.center = view.center
    view.addSubview(spinner)
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    directorRef?.stageDidAppear()
  }

  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
}


// MARK: ErrorDisplayer
extension Stage: ErrorDisplayer {
  
  func display(error: Error) {
    print((error as NSError).localizedDescription)
  }
}


// MARK: SpinnerDisplayer
extension Stage: SpinnerDisplayer {
  func hideSpinner() {
    spinner.stopAnimating()
  }
  
  func showSpinner() {
    spinner.startAnimating()
  }
}
