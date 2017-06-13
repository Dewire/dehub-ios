//
//  HomeView.swift
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

class HomeView: View {

  override var getViewModel: ViewModel { return viewModel }
  @IBOutlet weak var tableView: UITableView!
  
  var inputs: HomeViewModel.Inputs {
    return HomeViewModel.Inputs(
      logoutButtonTap: navigationItem.leftBarButtonItem!.rx.tap,
      addButtonTap: navigationItem.rightBarButtonItem!.rx.tap,

      rowTap: tableView.rx.itemSelected.map { [unowned self] indexPath in
        try? self.tableView.rx.model(at: indexPath)
      }.withoutNils(),
      
      refresh: refreshControl.rx.controlEvent(UIControlEvents.valueChanged)
    )
  }
  
  private var viewModel: HomeViewModel!
  
  private var refreshControl: UIRefreshControl!

  override public func viewDidLoad() {
    super.viewDidLoad()
    setupBarButtons()
    refreshControl = UIRefreshControl()
    tableView.addSubview(refreshControl)
    viewModel = HomeViewModel(services: services)
  }

  private func setupBarButtons() {
    let logout = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.done, target: nil, action: nil)
    self.navigationItem.leftBarButtonItem = logout
    
    let plus = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
    self.navigationItem.rightBarButtonItem = plus
  }

  override func startObserving(bag: DisposeBag) {
    let viewModelOutputs = viewModel.observe(inputs: inputs, bag: bag)
    observeViewModelOutputs(viewModelOutputs, bag: bag)
  }

  private func observeViewModelOutputs(_ outputs: HomeViewModel.Outputs, bag: DisposeBag) {

    outputs.gists.drive(tableView.rx.items(dataSource: dataSource)).addDisposableTo(bag)

    outputs.navigateNewGist.drive(onNext: {
      self.performSegue(withIdentifier: "CREATE_GIST_SEGUE", sender: nil)
    }).addDisposableTo(bag)

    outputs.navigateViewGist.drive(onNext: { gist in
      self.performSegue(withIdentifier: "VIEW_GIST_SEGUE", sender: gist)
    }).addDisposableTo(bag)

    outputs.stopRefresh.drive(onNext: { _ in
      self.refreshControl.endRefreshing()
    }).disposed(by: bag)
  }

  open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "VIEW_GIST_SEGUE" {
      (segue.destination as! ViewGistView).gist = (sender as! GistEntity)
    }
  }
}

extension HomeView {
  
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
