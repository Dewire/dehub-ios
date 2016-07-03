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

public protocol NavigationContext: Presentation {
  func push(stage: UIViewController)
  func pop()
}

public class NavigationControllerContext: NavigationContext {

  weak var navigationController: UINavigationController!
  let animated: Bool

  public init(controller: UINavigationController, animated: Bool = true) {
    self.navigationController = controller
    self.animated = animated
  }

  public func push(stage: UIViewController) {
    navigationController.pushViewController(stage, animated: animated)
  }

  public func pop() {
    navigationController.popViewControllerAnimated(animated)
  }

  public func present(stage: UIViewController) {
    push(stage)
    //if let navigationController = navigationController {
    //  navigationController.presentViewController(stage, animated: animated, completion: nil)
    //}
  }
}
