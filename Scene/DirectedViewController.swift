import UIKit
import RxSwift

typealias Closure = () -> Void

class DirectedViewController: UIViewController {
  
  let bag = DisposeBag()
  
  var directorRef: AnyObject?
  
  var afterLoad: Closure?
  
  let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    spinner.color = UIColor.red
    return spinner
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSpinner()
    afterLoad?()
    afterLoad = nil
  }
  
  private func setupSpinner() {
    spinner.center = view.center
    view.addSubview(spinner)
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
}


// MARK: ErrorDisplayer
extension DirectedViewController: ErrorDisplayer {
  
  func display(error: Error) {
    print((error as NSError).localizedDescription)
  }
}


// MARK: SpinnerDisplayer
extension DirectedViewController: SpinnerDisplayer {
  func hideSpinner() {
    spinner.stopAnimating()
  }
  
  func showSpinner() {
    spinner.startAnimating()
  }
}
