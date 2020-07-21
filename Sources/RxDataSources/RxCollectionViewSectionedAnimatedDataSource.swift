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

open class RxCollectionViewSectionedAnimatedDataSource<Section: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<Section>
    , RxCollectionViewDataSourceType {
    public typealias Element = [Section]
    public typealias DecideViewTransition = (CollectionViewSectionedDataSource<Section>, UICollectionView, [Changeset<Section>]) -> ViewTransition

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
    
    private var latestSections: [Section] = []

    open func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
            defer {
                dataSource.latestSections = newSections
            }
            
            #if DEBUG
                dataSource._dataSourceBound = true
            #endif
            if !dataSource.dataSet {
                dataSource.dataSet = true
                OperationQueue.main.addOperation(UpdateOperation(dataSource: dataSource, collectionView: collectionView, updateType: .reload(sections: newSections)))
            }
            else {
                // if view is not in view hierarchy, performing batch updates will crash the app
                if collectionView.window == nil {
                    OperationQueue.main.addOperation(UpdateOperation(dataSource: dataSource, collectionView: collectionView, updateType: .reload(sections: newSections)))
                    return
                }

                do {
                    let differences = try Diff.differencesForSectionedView(initialSections: dataSource.latestSections, finalSections: newSections)
                    
                    switch dataSource.decideViewTransition(dataSource, collectionView, differences) {
                    case .animated:
                        OperationQueue.main.addOperation(UpdateOperation(dataSource: dataSource, collectionView: collectionView, updateType: .animated(changesets: differences)))
                    case .reload:
                        OperationQueue.main.addOperation(UpdateOperation(dataSource: dataSource, collectionView: collectionView, updateType: .reload(sections: newSections)))
                        return
                    }
                }
                catch let e {
                    rxDebugFatalError(e)
                    OperationQueue.main.addOperation(UpdateOperation(dataSource: dataSource, collectionView: collectionView, updateType: .reload(sections: newSections)))
                }
            }
        }.on(observedEvent)
    }
}

private class UpdateOperation<Section: AnimatableSectionModelType>: Operation {
    enum UpdateType {
        case animated(changesets: [Changeset<Section>])
        case reload(sections: [Section])
    }
    
    private weak var dataSource: RxCollectionViewSectionedAnimatedDataSource<Section>?
    private weak var collectionView: UICollectionView?
    private let updateType: UpdateType
    
    override var isExecuting: Bool {
        _isExecuting
    }
    
    override var isFinished: Bool {
        _isFinished
    }
    
    override var isConcurrent: Bool {
        switch updateType {
        case .animated:
            return true
        case .reload:
            return false
        }
    }
    
    override var isAsynchronous: Bool {
        switch updateType {
        case .animated:
            return true
        case .reload:
            return false
        }
    }
    
    private var _isExecuting: Bool = false
    private var _isFinished: Bool = false
    
    required init(dataSource: RxCollectionViewSectionedAnimatedDataSource<Section>, collectionView: UICollectionView, updateType: UpdateType) {
        self.dataSource = dataSource
        self.collectionView = collectionView
        self.updateType = updateType
        
        super.init()
    }
    
    override func start() {
        guard !isCancelled, let dataSource = dataSource, let collectionView = collectionView else {
            willChangeValue(for: \.isFinished)
            _isFinished = true
            didChangeValue(for: \.isFinished)
            return
        }
        
        willChangeValue(for: \.isExecuting)
        _isExecuting = true
        didChangeValue(for: \.isExecuting)
        
        switch updateType {
        case .animated(let changesets):
            if !changesets.isEmpty {
                var updatesInProgress = changesets.count
                for changeset in changesets {
                    let updateBlock = { [weak dataSource, weak collectionView] in
                        // sections must be set within updateBlock in 'performBatchUpdates'
                        dataSource?.setSections(changeset.finalSections)
                        collectionView?.batchUpdates(changeset, animationConfiguration: dataSource?.animationConfiguration ?? .init())
                    }
                    
                    collectionView.performBatchUpdates(updateBlock, completion: { [weak self] animated in
                        guard let self = self else { return }
                        
                        updatesInProgress -= 1
                        
                        if updatesInProgress == 0 {
                            self.finish()
                        }
                    })
                }
            }
            else {
                finish()
            }
        case .reload(let sections):
            dataSource.setSections(sections)
            collectionView.reloadData()
            finish()
        }
    }
    
    private func finish() {
        willChangeValue(for: \.isExecuting)
        _isExecuting = false
        didChangeValue(for: \.isExecuting)
        
        willChangeValue(for: \.isFinished)
        _isFinished = true
        didChangeValue(for: \.isFinished)
    }
}

#endif
