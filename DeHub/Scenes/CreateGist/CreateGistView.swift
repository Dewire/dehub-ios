//
//  CreateGistView.swift
//  DeHub
//
//  Created by Kalle Lindström on 05/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Toaster

class CreateGistView: View {
  
  @IBOutlet weak var titleText: UITextField!
  @IBOutlet weak var contentText: UITextView!
  @IBOutlet weak var privatePublicSegment: UISegmentedControl!

  override var getViewModel: ViewModel { return viewModel }
  private var viewModel: CreateGistViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = CreateGistViewModel(services: services)
    let save = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: nil, action: nil)
    navigationItem.rightBarButtonItem = save
  }

  override func startObserving(bag: DisposeBag) {
    let viewModelOutputs = viewModel.observe(inputs: inputs)

    viewModelOutputs.saveButtonEnabled.drive(navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: bag)

    viewModelOutputs.showGistCreated.drive(onNext: {
      Toast(text: L("Gist created")).show()
    }).disposed(by: bag)
  }
}

extension CreateGistView {

  var inputs: CreateGistViewModel.Inputs {
    return CreateGistViewModel.Inputs(
      saveButtonTapped: navigationItem.rightBarButtonItem!.rx.tap,
      titleText: titleText.rx.text,
      contentText: contentText.rx.text,
      privatePublic: privatePublicSegment.rx.value
    )
  }
}
