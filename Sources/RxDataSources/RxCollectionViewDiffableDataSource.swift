//
//  RxCollectionViewDiffableDataSource.swift
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
open class RxCollectionViewDiffableDataSource<Section: DiffableSectionModelType>
	: CollectionViewDiffableDataSource<Section>
	, RxCollectionViewDataSourceType {
	public typealias Element = [Section]
	
	open func collectionView(_ collectionView: UICollectionView, observedEvent: RxSwift.Event<[Section]>) {
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
open class RxCollectionViewAnimatedDiffableDataSource<Section: DiffableSectionModelType>
	: CollectionViewDiffableDataSource<Section>
	, RxCollectionViewDataSourceType {
	public typealias Element = [Section]
	public typealias DecideViewTransition = (CollectionViewDiffableDataSource<Section>, UICollectionView, NSDiffableDataSourceSnapshot<Section, Section.Item>) -> ViewTransition
		
	/// Calculates view transition depending on type of changes
	open var decideViewTransition: DecideViewTransition
	
	public init(
		collectionView: UICollectionView,
		decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
		configureCell: @escaping ConfigureCellProvider,
		configureSupplementaryView: @escaping ConfigureSupplementaryViewProvider = { _, _, _, _ in nil },
		moveItem: @escaping MoveItemProvider = { _, _, _ in () },
		canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPathProvider = { _, _ in true }
	) {
		self.decideViewTransition = decideViewTransition
		super.init(collectionView: collectionView,
				   configureCell: configureCell,
				   configureSupplementaryView: configureSupplementaryView,
				   moveItem: moveItem,
				   canMoveItemAtIndexPath: canMoveItemAtIndexPath)
	}
	
	open func collectionView(_ collectionView: UICollectionView, observedEvent: RxSwift.Event<[Section]>) {
		Binder(self) { dataSource, sections in
			var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
			snapshot.appendSections(sections)
			sections.forEach { section in
				snapshot.appendItems(section.items, toSection: section)
			}
			let animated = dataSource.decideViewTransition(dataSource, collectionView, snapshot) == .animated
			dataSource.apply(snapshot, animatingDifferences: animated)
		}.on(observedEvent)
	}
}

#endif
