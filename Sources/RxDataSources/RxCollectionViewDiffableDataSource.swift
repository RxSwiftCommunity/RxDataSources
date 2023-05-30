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
	
	open func collectionView(_ collectionView: UICollectionView, observedEvent: RxSwift.Event<[Section]>) {
		var firstLoad = true
		
		Binder(self) { dataSource, sections in
			var snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>()
			snapshot.appendSections(sections)
			sections.forEach { section in
				snapshot.appendItems(section.items, toSection: section)
			}
			dataSource.apply(snapshot, animatingDifferences: !firstLoad, completion: { firstLoad = false })
		}.on(observedEvent)
	}
}

#endif
