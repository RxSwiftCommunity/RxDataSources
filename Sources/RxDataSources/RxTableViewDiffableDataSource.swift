//
//  RxTableViewDiffableDataSource.swift
//  
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

@available(iOS 13.0, tvOS 13.0, *)
open class RxTableViewDiffableDataSource<Section: DiffableSectionModelType>
	: TableViewDiffableDataSource<Section>
	, RxTableViewDataSourceType {
	public typealias Element = [Section]
	
	open func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[Section]>) {
		Binder(self) { dataSource, sections in
			var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
			snapshot.appendSections(sections)
			sections.forEach { section in
				snapshot.appendItems(section.items, toSection: section)
			}
			dataSource.apply(snapshot, animatingDifferences: false)
		}.on(observedEvent)
	}
}

@available(iOS 13.0, tvOS 13.0, *)
open class RxTableViewAnimatedDiffableDataSource<Section: DiffableSectionModelType>
: TableViewDiffableDataSource<Section>
, RxTableViewDataSourceType {
	public typealias Element = [Section]
	public typealias DecideViewTransition = (TableViewDiffableDataSource<Section>, UITableView, NSDiffableDataSourceSnapshot<Section, Section.Item>) -> ViewTransition
	
	/// Calculates view transition depending on type of changes
	public var decideViewTransition: DecideViewTransition
	
#if os(iOS)
	public init(
		tableView: UITableView,
		animation: UITableView.RowAnimation = .automatic,
		decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
		configureCell: @escaping ConfigureCell,
		titleForHeaderInSectionProvider: @escaping TitleForHeaderInSectionProvider = { _, _ in nil },
		titleForFooterInSectionProvider: @escaping TitleForFooterInSectionProvider = { _, _ in nil },
		canEditRowAtIndexPathProvider: @escaping CanEditRowAtIndexPathProvider = { _, _ in true },
		canMoveRowAtIndexPathProvider: @escaping CanMoveRowAtIndexPathProvider = { _, _ in true },
		sectionIndexTitles: @escaping SectionIndexTitlesProvider = { _ in nil },
		sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitleProvider = { _, _, index in index }
	) {
		self.decideViewTransition = decideViewTransition
		super.init(tableView: tableView,
				   configureCell: configureCell,
				   titleForHeaderInSectionProvider: titleForHeaderInSectionProvider,
				   titleForFooterInSectionProvider: titleForFooterInSectionProvider,
				   canEditRowAtIndexPathProvider: canEditRowAtIndexPathProvider,
				   canMoveRowAtIndexPathProvider: canMoveRowAtIndexPathProvider,
				   sectionIndexTitles: sectionIndexTitles,
				   sectionForSectionIndexTitle: sectionForSectionIndexTitle)
		defaultRowAnimation = animation
	}
#else
	public init(
		tableView: UITableView,
		animation: UITableView.RowAnimation = .automatic,
		decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
		configureCell: @escaping ConfigureCell,
		titleForHeaderInSectionProvider: @escaping TitleForHeaderInSectionProvider = { _, _ in nil },
		titleForFooterInSectionProvider: @escaping TitleForFooterInSectionProvider = { _, _ in nil },
		canEditRowAtIndexPathProvider: @escaping CanEditRowAtIndexPathProvider = { _, _ in true },
		canMoveRowAtIndexPathProvider: @escaping CanMoveRowAtIndexPathProvider = { _, _ in true }
	) {
		self.decideViewTransition = decideViewTransition
		super.init(tableView: tableView,
				   configureCell: configureCell,
				   titleForHeaderInSectionProvider: titleForHeaderInSectionProvider,
				   titleForFooterInSectionProvider: titleForFooterInSectionProvider,
				   canEditRowAtIndexPathProvider: canEditRowAtIndexPathProvider,
				   canMoveRowAtIndexPathProvider: canMoveRowAtIndexPathProvider)
		defaultRowAnimation = animation
	}
#endif
	
	open func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[Section]>) {
		Binder(self) { dataSource, sections in
			var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
			snapshot.appendSections(sections)
			sections.forEach { section in
				snapshot.appendItems(section.items, toSection: section)
			}
			let animated = dataSource.decideViewTransition(dataSource, tableView, snapshot) == .animated
			dataSource.apply(snapshot, animatingDifferences: animated)
		}.on(observedEvent)
	}
}

#endif
