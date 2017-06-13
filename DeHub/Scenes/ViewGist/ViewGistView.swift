//
//  ViewGistView.swift
//  DeHub
//
//  Created by Kalle Lindström on 15/09/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class ViewGistView: View {

  override var getViewModel: ViewModel { return viewModel }
  private var viewModel: ViewGistViewModel!

  @IBOutlet weak var textViewContainer: UIScrollView!
  weak var textView: DualScrollableTextView!

  var gist: GistEntity?

  func setText(text: String) {
    textView.text = text
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let gist = gist else { fatalError("gist cannot be nil") }
    viewModel = ViewGistViewModel(services: services, gist: gist)
    addTextView()
  }

  override func startObserving(bag: DisposeBag) {
    let viewModelOutputs = viewModel.observe()

    viewModelOutputs.title.drive(rx.title).disposed(by: bag)
    viewModelOutputs.text.drive(textView.rx.text).disposed(by: bag)
  }

  private func addTextView() {
    textView = DualScrollableTextView()
    textView.font = UIFont(name: "Menlo", size: 14)!
    textView.autocorrectionType = .no
    textView.isEditable = false
    textViewContainer.addSubview(textView)
  }
}
