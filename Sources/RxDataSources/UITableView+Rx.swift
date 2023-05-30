//
//  UITableView+Rx.swift
//  RxDataSources
//
//  Created by mlch911 on 2023/5/30.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public extension Reactive where Base: UITableView {
	@available(iOS 13.0, tvOS 13.0, *)
	public func items<
		Section,
		DataSource: RxTableViewDataSourceType & TableViewDiffableDataSource<Section>,
		Source: ObservableType>
	(dataSource: DataSource)
	-> (_ source: Source)
	-> Disposable
	where DataSource.Element == Source.Element {
		return { source in
			_ = self.delegate
			return source.subscribe { [weak tableView = self.base] event -> Void in
				guard let tableView = tableView else {
					return
				}
				dataSource.tableView(tableView, observedEvent: event)
			}
		}
	}
}

#endif
