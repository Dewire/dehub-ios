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
import RxDataSources
import Model

class HomeStage : DirectedViewController {
  
  struct Outputs {
    let logoutButtonTap: ControlEvent<Void>
    let addButtonTap: ControlEvent<Void>
    let rowTap: Observable<GistEntity?>
    let refresh: ControlEvent<Void>
  }
  
  var outputs: Outputs {
    return Outputs(
      logoutButtonTap: navigationItem.leftBarButtonItem!.rx.tap,
      addButtonTap: navigationItem.rightBarButtonItem!.rx.tap,
      
      rowTap: tableView.rx.itemSelected.map { [unowned self] indexPath in
        try? self.tableView.rx.model(at: indexPath)
      },
      
      refresh: refreshControl.rx.controlEvent(UIControlEvents.valueChanged)
    )
  }
  
  struct Inputs {
    let tableView: Reactive<UITableView>
    let tableViewDataSource: RxTableViewSectionedReloadDataSource<GistSection>
    let source: Variable<[GistSection]>
  }
  
  var inputs: Inputs {
    return Inputs(
      tableView: tableView.rx,
      tableViewDataSource: dataSource,
      source: gists
    )
  }
  
  private let gists = Variable<[GistSection]>([])
  
  @IBOutlet weak var tableView: UITableView!
  var refreshControl: UIRefreshControl!
  
  static func create() -> HomeStage {
    let storyboard = UIStoryboard(name: "Home", bundle: Bundle(for: HomeScene.self))
    return storyboard.instantiateInitialViewController() as! HomeStage
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
    
    gists.asObservable().bindTo(tableView.rx.items(dataSource: dataSource))
      .addDisposableTo(bag)
  }
  
  func stopRefreshing() {
    refreshControl.endRefreshing()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let selected = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selected, animated: false)
    }
  }
  
  func setGists(gists: [GistEntity]) {
    
  }
}


extension HomeStage {
  
  fileprivate var dataSource: RxTableViewSectionedReloadDataSource<GistSection> {
    let source = RxTableViewSectionedReloadDataSource<GistSection>()
    
    source.titleForHeaderInSection = { dataSource, index in
      dataSource.sectionModels[index].header
    }
    
    source.configureCell = { [weak self] dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "GistCell", for: indexPath) as! GistTableViewCell
      self?.configure(cell: cell, withModel: item)
      return cell
    }
    
    return source
  }
  
  private func configure(cell: GistTableViewCell, withModel model: GistEntity) {
    cell.titleLabel.text = model.description.isEmpty ? model.file.filename : model.description
    cell.languageLabel.text = model.file.language ?? ""
  }
}

