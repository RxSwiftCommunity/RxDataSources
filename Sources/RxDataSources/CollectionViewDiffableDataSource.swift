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
	
	public enum Error: Swift.Error {
		case outOfBounds(indexPath: IndexPath)
	}
	
	public typealias ConfigureCellProvider = (_ dataSource: CollectionViewDiffableDataSource<Section>, _ collectionView: UICollectionView, _ indexPath: IndexPath, Section.Item) -> UICollectionViewCell
	public typealias ConfigureSupplementaryViewProvider = (_ dataSource: CollectionViewDiffableDataSource<Section>, _ collectionView: UICollectionView, _ elementKind: String, _ indexPath: IndexPath) -> UICollectionReusableView?
	public typealias MoveItemProvider = (_ dataSource: CollectionViewDiffableDataSource<Section>, _ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void
	public typealias CanMoveItemAtIndexPathProvider = (_ dataSource: CollectionViewDiffableDataSource<Section>, _ indexPath: IndexPath) -> Bool
	
	open var configureSupplementaryView: ConfigureSupplementaryViewProvider?
	open var canMoveItemAtIndexPath: CanMoveItemAtIndexPathProvider?
	open var moveItem: MoveItemProvider?
	
	public init(
		collectionView: UICollectionView,
		configureCell: @escaping ConfigureCellProvider,
		configureSupplementaryView: @escaping ConfigureSupplementaryViewProvider = { _, _, _, _ in nil },
		moveItem: @escaping MoveItemProvider = { _, _, _ in () },
		canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPathProvider = { _, _ in true }
	) {
		self.moveItem = moveItem
		self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
		self.configureSupplementaryView = configureSupplementaryView
		weak var dataSource: CollectionViewDiffableDataSource<Section>!
		super.init(collectionView: collectionView, cellProvider: {
			configureCell(dataSource, $0, $1, $2)
		})
		self.supplementaryViewProvider = { [unowned self] in
			self.configureSupplementaryView?(self, $0, $1, $2)
		}
		dataSource = self
	}
	
	// MARK: - UICollectionViewDataSource
	open override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		canMoveItemAtIndexPath?(self, indexPath) ?? false
	}
	
	open override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		self.moveItem?(self, sourceIndexPath, destinationIndexPath)
	}
}

extension CollectionViewDiffableDataSource: SectionedViewDataSourceType {
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

public extension CollectionViewDiffableDataSource {
	func numberOfSections() -> Int {
		snapshot().numberOfSections
	}
	
	func numberOfItems(in section: Int) -> Int {
		let snapshot = snapshot()
		guard section >= 0, section < snapshot.sectionIdentifiers.count else { return 0 }
		return snapshot.numberOfItems(inSection: snapshot.sectionIdentifiers[section])
	}
}

#endif

