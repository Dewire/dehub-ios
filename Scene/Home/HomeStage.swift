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
  
  var refreshControl: UIRefreshControl!
  
  static func create(_ directorFactory: @escaping (HomeStage) -> HomeDirector) -> HomeStage {
    let storyboard = UIStoryboard(name: "Home", bundle: Bundle(for: HomeScene.self))
    return create(storyboard, directorFactory: downcast(directorFactory)) as! HomeStage
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupBarButtons()
    refreshControl = UIRefreshControl()
  }
  
  private func setupBarButtons() {
    let logout = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.done, target: nil, action: nil)
    self.navigationItem.leftBarButtonItem = logout
    
    let plus = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    self.navigationItem.rightBarButtonItem = plus
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.addSubview(refreshControl)
    
  }
  
  override func bind(director: HomeDirector) {
    observeGists(director: director)
    observeEndRefreshing(director: director)
    observeShowLoadingIndicator(director: director)
  }
  
  private func observeGists(director: HomeDirector) {
    director.gists.asDriver()
      .drive(tableView.rx.items(cellIdentifier: "GistCell", cellType: GistTableViewCell.self)) { [unowned self] (row, model, cell) in
        self.configure(cell: cell, withModel: model)
      }
      .addDisposableTo(bag)
  }
  
  private func observeEndRefreshing(director: HomeDirector) {
    director.endRefreshing.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [unowned self] in
        self.refreshControl.endRefreshing()
      })
      .addDisposableTo(bag)
  }
  
  private func observeShowLoadingIndicator(director: HomeDirector) {
    director.showLoadingIndicator.asDriver().drive(onNext: { [unowned self] show in
      if show {
        self.view.showLoadingIndicator(style: .whiteLarge, color: .gray, zPosition: 1)
      } else {
        self.view.hideLoadingIndicator()
      }
    })
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
    let rowTap: Observable<GistEntity>
    let refresh: ControlEvent<Void>
  }
  
  var actions: Actions {
    return Actions(
      logoutButtonTap: navigationItem.leftBarButtonItem!.rx.tap,
      addButtonTap: navigationItem.rightBarButtonItem!.rx.tap,
      
      rowTap: tableView.rx.itemSelected.map { [unowned self] indexPath in
        do {
          let model: GistEntity = try self.tableView.rx.model(indexPath)
          return model
        }
        catch {
          throw error
        }
      },
      
      refresh: refreshControl.rx.controlEvent(UIControlEvents.valueChanged)
    )
  }
}
