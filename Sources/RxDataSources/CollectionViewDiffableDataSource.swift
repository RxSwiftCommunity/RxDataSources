//
//  CollectionViewDiffableDataSource.swift
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
open class CollectionViewDiffableDataSource<Section: DiffableSectionModelType>:
	UICollectionViewDiffableDataSource<Section, Section.Item> {
	
	enum Error: Swift.Error {
		case outOfBounds(indexPath: IndexPath)
	}
	
	typealias CanMoveItemAtIndexPathProvider = (CollectionViewDiffableDataSource<Section>, IndexPath) -> Bool
	
	private let _canMoveItemAtIndexPathProvider: CanMoveItemAtIndexPathProvider
	
	init(
		collectionView: UICollectionView,
		cellProvider: @escaping CellProvider,
		supplementaryViewProvider: SupplementaryViewProvider? = { _, _, _ in nil },
		canMoveRowAtIndexPathProvider: @escaping CanMoveItemAtIndexPathProvider = { _, _ in true }
	) {
		_canMoveItemAtIndexPathProvider = canMoveRowAtIndexPathProvider
		super.init(collectionView: collectionView, cellProvider: cellProvider)
		self.supplementaryViewProvider = supplementaryViewProvider
	}
	
	// MARK: - UICollectionViewDataSource
	open override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return _canMoveItemAtIndexPathProvider(self, indexPath)
	}
}

extension CollectionViewDiffableDataSource: SectionedViewDataSourceType {
	public func model(at indexPath: IndexPath) throws -> Any {
		guard let item = itemIdentifier(for: indexPath) else { throw Error.outOfBounds(indexPath: indexPath) }
		return item
	}
	
	public func sectionModel(at index: Int) -> Section? {
		if #available(iOS 15.0, tvOS 15.0, *) {
			return sectionIdentifier(for: index)
		}
		let sections = snapshot().sectionIdentifiers
		guard index >= 0 && index < sections.count else { return nil }
		return sections[index]
	}
	
	public subscript(section: Int) -> Section? {
		sectionModel(at: section)
	}
	
	public subscript(indexPath: IndexPath) -> Section.Item? {
		itemIdentifier(for: indexPath)
	}
}

public extension CollectionViewDiffableDataSource {
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

