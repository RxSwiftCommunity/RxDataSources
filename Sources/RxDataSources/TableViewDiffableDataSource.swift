//
//  TableViewDiffableDataSource.swift
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
open class TableViewDiffableDataSource<Section: DiffableSectionModelType>:
	UITableViewDiffableDataSource<Section, Section.Item> {
	
	enum Error: Swift.Error {
		case outOfBounds(indexPath: IndexPath)
	}
	
	public typealias ConfigureCell = (TableViewDiffableDataSource<Section>, UITableView, IndexPath, Section.Item) -> UITableViewCell
	public typealias TitleForHeaderInSectionProvider = (TableViewDiffableDataSource<Section>, Int) -> String?
	public typealias TitleForFooterInSectionProvider = (TableViewDiffableDataSource<Section>, Int) -> String?
	public typealias CanEditRowAtIndexPathProvider = (TableViewDiffableDataSource<Section>, IndexPath) -> Bool
	public typealias CanMoveRowAtIndexPathProvider = (TableViewDiffableDataSource<Section>, IndexPath) -> Bool
#if os(iOS)
	public typealias SectionIndexTitlesProvider = (TableViewDiffableDataSource<Section>) -> [String]?
	public typealias SectionForSectionIndexTitleProvider = (TableViewDiffableDataSource<Section>, _ title: String, _ index: Int) -> Int
#endif
	
	public var titleForHeaderInSectionProvider: TitleForHeaderInSectionProvider
	public var titleForFooterInSectionProvider: TitleForFooterInSectionProvider
	public var canEditRowAtIndexPathProvider: CanEditRowAtIndexPathProvider
	public var canMoveRowAtIndexPathProvider: CanMoveRowAtIndexPathProvider
#if os(iOS)
	public var sectionIndexTitlesProvider: SectionIndexTitlesProvider
	public var sectionForSectionIndexTitleProvider: SectionForSectionIndexTitleProvider
#endif
	
#if os(iOS)
	public init(
		tableView: UITableView,
		configureCell: @escaping ConfigureCell,
		titleForHeaderInSectionProvider: @escaping TitleForHeaderInSectionProvider = { _, _ in nil },
		titleForFooterInSectionProvider: @escaping TitleForFooterInSectionProvider = { _, _ in nil },
		canEditRowAtIndexPathProvider: @escaping CanEditRowAtIndexPathProvider = { _, _ in true },
		canMoveRowAtIndexPathProvider: @escaping CanMoveRowAtIndexPathProvider = { _, _ in true },
		sectionIndexTitles: @escaping SectionIndexTitlesProvider = { _ in nil },
		sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitleProvider = { _, _, index in index }
	) {
		self.titleForHeaderInSectionProvider = titleForHeaderInSectionProvider
		self.titleForFooterInSectionProvider = titleForFooterInSectionProvider
		self.canEditRowAtIndexPathProvider = canEditRowAtIndexPathProvider
		self.canMoveRowAtIndexPathProvider = canMoveRowAtIndexPathProvider
		self.sectionIndexTitlesProvider = sectionIndexTitles
		self.sectionForSectionIndexTitleProvider = sectionForSectionIndexTitle
		weak var dataSource: TableViewDiffableDataSource<Section>!
		super.init(tableView: tableView, cellProvider: {
			configureCell(dataSource, $0, $1, $2)
		})
		dataSource = self
	}
#else
	public init(
		tableView: UITableView,
		configureCell: @escaping ConfigureCell,
		titleForHeaderInSectionProvider: @escaping TitleForHeaderInSectionProvider = { _, _ in nil },
		titleForFooterInSectionProvider: @escaping TitleForFooterInSectionProvider = { _, _ in nil },
		canEditRowAtIndexPathProvider: @escaping CanEditRowAtIndexPathProvider = { _, _ in true },
		canMoveRowAtIndexPathProvider: @escaping CanMoveRowAtIndexPathProvider = { _, _ in true }
	) {
		_titleForHeaderInSectionProvider = titleForHeaderInSectionProvider
		_titleForFooterInSectionProvider = titleForFooterInSectionProvider
		_canEditRowAtIndexPathProvider = canEditRowAtIndexPathProvider
		_canMoveRowAtIndexPathProvider = canMoveRowAtIndexPathProvider
		weak var dataSource: TableViewDiffableDataSource<Section>!
		super.init(tableView: tableView, cellProvider: {
			configureCell(dataSource, $0, $1, $2)
		})
		dataSource = self
	}
#endif
	
	// MARK: - UITableViewDataSource
	open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return titleForHeaderInSectionProvider(self, section)
	}
	
	open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return titleForFooterInSectionProvider(self, section)
	}
	
	open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return canEditRowAtIndexPathProvider(self, indexPath)
	}
	
	open override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return canMoveRowAtIndexPathProvider(self, indexPath)
	}
	
#if os(iOS)
	open override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return sectionIndexTitlesProvider(self)
	}
	
	open override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return sectionForSectionIndexTitleProvider(self, title, index)
	}
#endif
}

extension TableViewDiffableDataSource: SectionedViewDataSourceType {
	open func model(at indexPath: IndexPath) throws -> Any {
		guard let item = itemIdentifier(for: indexPath) else { throw Error.outOfBounds(indexPath: indexPath) }
		return item
	}
	
	open func sectionModel(at index: Int) -> Section? {
		if #available(iOS 15.0, tvOS 15.0, *) {
			return sectionIdentifier(for: index)
		}
		let sections = snapshot().sectionIdentifiers
		guard index >= 0 && index < sections.count else { return nil }
		return sections[index]
	}
	
	open subscript(section: Int) -> Section? {
		sectionModel(at: section)
	}
	
	open subscript(indexPath: IndexPath) -> Section.Item? {
		itemIdentifier(for: indexPath)
	}
}

public extension TableViewDiffableDataSource {
	func numberOfSections() -> Int {
		snapshot().numberOfSections
	}
	
	func numberOfRows(in section: Int) -> Int {
		let snapshot = snapshot()
		guard section >= 0, section < snapshot.sectionIdentifiers.count else { return 0 }
		return snapshot.numberOfItems(inSection: snapshot.sectionIdentifiers[section])
	}
}

#endif
