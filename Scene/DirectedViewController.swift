

import UIKit
import RxSwift
import Siesta
import SiestaUI

typealias Closure = () -> Void

class DirectedViewController : UIViewController {
  
  let bag = DisposeBag()
  var directorRef: AnyObject?
  
  var afterLoad: Closure?
  
  let overlay: ResourceStatusOverlay = {
    let o = ResourceStatusOverlay()
    o.displayPriority = [.ManualLoading, .Loading, .Error, .AnyData]
    return o
  }()
  
  var overlayResources: [Resource] = [] {
    didSet {
      oldValue.forEach { $0.removeObservers(ownedBy: overlay) }
      overlayResources.forEach { $0.addObserver(overlay) }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    embedOverlay()
    afterLoad?()
    afterLoad = nil
  }
  
  private func embedOverlay() {
    overlay.embedIn(self)
    overlay.backgroundColor = overlay.backgroundColor?.withAlphaComponent(0.5)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    overlay.positionToCoverParent()
  }
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
}


extension Request {
  
  @discardableResult
  func addToOverlay(stage: DirectedViewController) -> Request {
    stage.overlay.trackManualLoad(self)
    return self
  }
}
