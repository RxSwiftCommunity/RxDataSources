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

/*
 This is commented becuse collection view has bugs when doing animated updates. 
 Take a look at randomized sections.
*/
open class RxCollectionViewSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    public typealias Element = [S]
    public typealias DecideViewTransition = (CollectionViewSectionedDataSource<S>, UICollectionView, [Changeset<S>]) -> ViewTransition
    private enum Update {
        case reload(collectionView: UICollectionView, newSections: [S])
        case animated(collectionView: UICollectionView, differences: [Changeset<S>])
    }
    
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
        
        let cancelableAnimatedUpdates = PublishRelay<(UICollectionView, [Changeset<S>])?>()
        self.animatedUpdates.bind(to: cancelableAnimatedUpdates).disposed(by: disposeBag)
        let throttledAnimatedUpdates = cancelableAnimatedUpdates
            // so in case it does produce a crash, it will be after the data has changed
            .observeOn(MainScheduler.asyncInstance)
            // Collection view has issues digesting fast updates, this should
            // help to alleviate the issues with them.
            .throttle(0.5, scheduler: MainScheduler.instance)
            .filter { $0 != nil }
            .map { $0! }
        Observable.merge([
            self.reloadUpdates.map { Update.reload(collectionView: $0.0, newSections: $0.1) },
            throttledAnimatedUpdates.map { Update.animated(collectionView: $0.0, differences: $0.1) }
            ]).subscribe(onNext: { [weak self] update in
                guard let `self` = self else { return }
                switch update {
                case .reload(let collectionView, let newSections):
                    self.setSections(newSections)
                    collectionView.reloadData()
                    cancelableAnimatedUpdates.accept(nil) // Cancel any throttled animated updates as they are no longer valid
                case .animated(let collectionView, let differences):
                    for difference in differences {
                        self.setSections(difference.finalSections)
                        collectionView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                    }
                }
            }).disposed(by: self.disposeBag)
    }
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var dataSet = false
    
    private let disposeBag = DisposeBag()
    
    private let reloadUpdates = PublishRelay<(UICollectionView, [S])>()
    
    // This relay and throttle are here
    // because collection view has problems processing animated updates fast.
    // This should somewhat help to alleviate the problem.
    private let animatedUpdates = PublishRelay<(UICollectionView, [Changeset<S>])>()
    
    open func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
                self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                self.reloadUpdates.accept((collectionView, newSections))
            }
            else {
                do {
                    let oldSections = dataSource.sectionModels
                    let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    switch self.decideViewTransition(self, collectionView, differences) {
                    case .animated:
                        // if view is not in view hierarchy, performing batch updates will crash the app
                        if collectionView.window == nil {
                            self.reloadUpdates.accept((collectionView, newSections))
                            return
                        }
                        dataSource.animatedUpdates.accept((collectionView, differences))
                    case .reload:
                        self.reloadUpdates.accept((collectionView, newSections))
                    }
                }
                catch let e {
                    #if DEBUG
                    print("Error while binding data animated: \(e)\nFallback to normal `reloadData` behavior.")
                    rxDebugFatalError(e)
                    #endif
                    self.reloadUpdates.accept((collectionView, newSections))
                }
            }
        }.on(observedEvent)
    }
}
#endif
