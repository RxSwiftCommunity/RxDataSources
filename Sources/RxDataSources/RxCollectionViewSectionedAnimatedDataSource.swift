//
//  RxCollectionViewSectionedAnimatedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import Differentiator

open class RxCollectionViewSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    public typealias Element = [S]
    public typealias DecideViewTransition = (CollectionViewSectionedDataSource<S>, UICollectionView, [Changeset<S>]) -> ViewTransition

    // animation configuration
    public var animationConfiguration: AnimationConfiguration

    /// Calculates view transition depending on type of changes
    public var decideViewTransition: DecideViewTransition

    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideViewTransition = decideViewTransition
        super.init(
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView,
            moveItem: moveItem,
            canMoveItemAtIndexPath: canMoveItemAtIndexPath
        )
    }
    
    // there is no longer limitation to load initial sections with reloadData
    // but it is kept as a feature everyone got used to
    var dataSet = false

    open func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                collectionView.reloadData()
            }
            else {
                DispatchQueue.main.async {
                    // if view is not in view hierarchy, performing batch updates will crash the app
                    if collectionView.window == nil {
                        dataSource.setSections(newSections)
                        collectionView.reloadData()
                        return
                    }
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                        
                        switch self.decideViewTransition(self, collectionView, differences) {
                        case .animated:
                            // each difference must be run in a separate performBatchUpdate, otherwise it crashes.
                            // this is a limitation of Diff tool
                            for difference in differences {
                                collectionView.performBatchUpdates({ [unowned self] in
                                    // sections must be set within updateBlock in performBatchUpdates
                                    dataSource.setSections(difference.finalSections)
                                    collectionView.batchUpdates(difference, animationConfiguration: self.animationConfiguration)
                                    }, completion: nil)
                            }
                            
                        case .reload:
                            self.setSections(newSections)
                            collectionView.reloadData()
                            return
                        }
                    }
                    catch let e {
                        rxDebugFatalError(e)
                        self.setSections(newSections)
                        collectionView.reloadData()
                    }
                }
            }
        }.on(observedEvent)
    }
}
#endif
