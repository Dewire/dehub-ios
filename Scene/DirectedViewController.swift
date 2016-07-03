//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import RxSwift

public class DirectedViewController<D> : UIViewController {
  
  var bag: DisposeBag!

  public var director: D {
    if let director = _director {
      return director
    } else {
      fatalError("Director must not be accessed before view loads.")
    }
  }

  private var _director: D?
  private var directorFactory: (DirectedViewController -> D)!

  public init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: NSBundle? = nil, directorFactory: DirectedViewController -> D) {
    self.directorFactory = directorFactory
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  public static func create(storyboard: UIStoryboard, directorFactory: DirectedViewController -> D) -> DirectedViewController {
    let viewController = storyboard.instantiateInitialViewController() as! DirectedViewController
    viewController.directorFactory = directorFactory
    return viewController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    bag = DisposeBag()
    _director = directorFactory(self)
    directorFactory = nil
    bindDirector(director)
  }

  public func bindDirector(director: D) {}
  
  deinit {
    print("🗑 \(self.dynamicType) deinit")
  }
}

public func downcast<T, U, D>(closure: T -> D) -> (U -> D) {
  return { a in closure(a as! T) }
}
