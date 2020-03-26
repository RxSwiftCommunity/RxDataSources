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
			case let .add(section, sectionIdentifier):
				if let sectionIndex = dataSource.index(of: sectionIdentifier) {
					dataSource.insertSection(section, after: sectionIndex)
					tableView.insertSections(IndexSet(arrayLiteral: sectionIndex + 1), with: .fade)
				}
			case .load(let sections):
				dataSource.setSections(sections)
				tableView.reloadData()
			case .remove(let section):
				if let sectionIndex = dataSource.index(of: section) {
					dataSource.removeSection(at: sectionIndex)
					tableView.deleteSections(IndexSet(arrayLiteral: sectionIndex), with: .fade)
				}
			case .update(let section):
				if let sectionIndex = dataSource.index(of: section.identity) {
					dataSource.setSection(section, at: sectionIndex)
					tableView.reloadSections(IndexSet(arrayLiteral: sectionIndex), with: .fade)
				}
			}
		}.on(observedEvent)
	}

	private func index(of sectionIdentifier: Section.Identity) -> Int? {
		
		return sectionModels.firstIndex(where: { $0.identity == sectionIdentifier })
	}
}
