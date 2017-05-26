import UIKit
import RxSwift
import Model

class View: UIViewController {

  deinit {
    print("🗑 \(type(of: self)) deinit")
  }

  var services: Services {
    return Services.shared
  }
  
  private var bag: DisposeBag?
  
  let spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    spinner.color = UIColor.darkGray
    return spinner
  }()
  
  func startObserving(bag: DisposeBag) {
    fatalError("Override this method and observe the view model")
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    spinner.center = view.center
    view.addSubview(spinner)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    bag = DisposeBag()
    observeEvents(bag: bag!)
    startObserving(bag: bag!)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    bag = nil
  }

  private func observeEvents(bag: DisposeBag) {
    EventChannel.shared.events.subscribe(onNext: { event in
      self.handle(event: event)
    }).disposed(by: bag)
  }

  private func handle(event: Event) {
    switch event {
      case .showSpinner: spinner.startAnimating()
      case .hideSpinner: spinner.stopAnimating()
      case .displayError(let error): print("Error: \(error)")
    }
  }
}
