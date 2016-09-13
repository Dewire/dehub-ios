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

class DirectedViewController<D> : UIViewController {
  
  var bag: DisposeBag!

  var director: D {
    if let director = _director {
      return director
    } else {
      fatalError("Director must not be accessed before view loads.")
    }
  }

  fileprivate var _director: D?
  fileprivate var directorFactory: ((DirectedViewController<D>) -> D)!
  
  static func create(_ storyboard: UIStoryboard,
                     directorFactory: @escaping (DirectedViewController<D>) -> D) -> DirectedViewController<D> {

    let viewController = storyboard.instantiateInitialViewController() as! DirectedViewController<D>
    viewController.directorFactory = directorFactory
    return viewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bag = DisposeBag()
    _director = directorFactory(self)
    directorFactory = nil
    bindDirector(director)
  }

  func bindDirector(_ director: D) {}
  
  deinit {
    print("🗑 \(type(of: self)) deinit")
  }
}

// S = Stage, D = Director, T = Any object
// This function takes a directory factory closure of type S -> D.
// It then creates and returns a new closure of type T -> D
// It does this by force casting T to S, and then invoking the original closure with it.
func downcast<S, D, T>(_ closure: @escaping (S) -> D) -> ((T) -> D) {
  return { a in closure(a as! S) }
}
