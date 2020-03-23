//
//  RxTableViewSectionedCommandDataSource.swift
//  RxDataSources
//
//  Created by David Weiler-Thiessen on 2020-03-22.
//  Copyright © 2020 Saskatoon Skunkworx. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class RxTableViewSectionedCommandDataSource<Section: IdentifiableSectionModelType>
	: TableViewSectionedDataSource<Section>
	, RxTableViewDataSourceType {
	public typealias Element = SectionedDataSourceCommand<Section>

	open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
		Binder(self) { dataSource, element in
			switch element {
			case .load(let sections):
				dataSource.setSections(sections)
				tableView.reloadData()
			case .update(let section):
 				if let sectionIndex = dataSource.index(of: section) {
					dataSource.setSection(section, at: sectionIndex)
					tableView.reloadSections(IndexSet(arrayLiteral: sectionIndex), with: .fade)
				}
			}
		}.on(observedEvent)
	}

	private func index(of section: Section) -> Int? {
		
		return sectionModels.firstIndex(where: { $0.identity == section.identity })
	}
}
