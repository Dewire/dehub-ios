

import UIKit
import RxSwift

typealias Closure = () -> Void

class DirectedViewController : UIViewController {
  
  let bag = DisposeBag()
  var directorRef: AnyObject?
  
  var afterLoad: Closure?

  override func viewDidLoad() {
    super.viewDidLoad()
    afterLoad?()
    afterLoad = nil
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
}
