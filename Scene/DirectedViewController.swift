

import UIKit
import RxSwift
import Siesta
import SiestaUI

typealias Closure = () -> Void

class DirectedViewController : UIViewController {
  
  let bag = DisposeBag()
  var directorRef: AnyObject?
  
  var afterLoad: Closure?
  
  var overlay = ResourceStatusOverlay()
  
  var overlayResources: [Resource] = [] {
    didSet {
      print("RES: \(overlayResources)")
      oldValue.forEach { $0.removeObservers(ownedBy: overlay) }
      overlayResources.forEach { $0.addObserver(overlay) }
      overlay.embedIn(self)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    afterLoad?()
    afterLoad = nil
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
}
