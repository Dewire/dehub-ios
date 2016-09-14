//
//  HomeStage.swift
//  DeHub
//
//  Created by Kalle Lindström on 21/06/16.
//  Copyright © 2016 Dewire. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Model

class HomeStage : DirectedViewController<HomeDirector> {
  
  @IBOutlet weak var tableView: UITableView!
  
  static func create(_ directorFactory: @escaping (HomeStage) -> HomeDirector) -> HomeStage {
    let storyboard = UIStoryboard(name: "Home", bundle: Bundle(for: HomeScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! HomeStage
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupBarButtons()
  }
  
  fileprivate func setupBarButtons() {
    let logout = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.done, target: nil, action: nil)
    self.navigationItem.leftBarButtonItem = logout
    
    let plus = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    self.navigationItem.rightBarButtonItem = plus
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func bind(director: HomeDirector) {
    director.gists.asDriver()
      .drive(tableView.rx.items(cellIdentifier: "GistCell", cellType: GistTableViewCell.self)) { [unowned self] (row, model, cell) in
        self.configure(cell: cell, withModel: model)
      }
      .addDisposableTo(bag)
  }
  
  private func configure(cell: GistTableViewCell, withModel model: GistEntity) {
    cell.titleLabel.text = model.description.isEmpty ? model.file.filename : model.description
    cell.languageLabel.text = model.file.language ?? ""
  }
}

extension HomeStage {
  
  struct Actions {
    let logoutButtonTap: ControlEvent<Void>
    let addButtonTap: ControlEvent<Void>
  }
  
  var actions: Actions {
    return Actions(
      logoutButtonTap: self.navigationItem.leftBarButtonItem!.rx.tap,
      addButtonTap: self.navigationItem.rightBarButtonItem!.rx.tap
    )
  }
}
