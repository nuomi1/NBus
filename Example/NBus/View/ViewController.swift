//
//  ViewController.swift
//  NBus
//
//  Created by nuomi1 on 07/10/2020.
//  Copyright (c) 2020 nuomi1. All rights reserved.
//

import RxSwift
import UIKit

class ViewController: UIViewController {

    enum Constant {
        static let identifier = String(describing: UITableViewCell.self)
    }

    private let disposeBag = DisposeBag()

    private let tableView = UITableView()
}

extension ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.pin
            .all()
    }

    private func setupSubviews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constant.identifier)
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)
    }
}

extension ViewController {

    func binding(_ viewModel: ViewModel) {
        viewModel.title
            .bind(to: rx.title)
            .disposed(by: disposeBag)

        viewModel.platformItems
            .bind(to: tableView.rx.items)(dequeueCell)
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(AppState.PlatformItem.self)
            .bind(onNext: pushViewController)
            .disposed(by: disposeBag)

        tableView.rx
            .itemSelected
            .map { ($0, true) }
            .bind(onNext: tableView.deselectRow)
            .disposed(by: disposeBag)
    }

    private func dequeueCell(
        tableView: UITableView,
        row: Int,
        element: AppState.PlatformItem
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constant.identifier,
            for: IndexPath(row: row, section: 0)
        )

        cell.textLabel?.text = "\(element.platform)"

        return cell
    }

    private func pushViewController(element: AppState.PlatformItem) {
        guard
            let viewController = element.viewController() as? PlatformViewController
        else { assertionFailure(); return }

        viewController.binding(.init(element))

        navigationController?.pushViewController(viewController, animated: true)
    }
}
