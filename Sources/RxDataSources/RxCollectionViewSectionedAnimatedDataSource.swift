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
    public typealias DecideViewTransition = (CollectionViewSectionedDataSource<S>, UICollectionView, [Changeset<S>]) -> ViewTransition<UICollectionView>

    // animation configuration
    public var animationConfiguration: AnimationConfiguration

    /// Calculates view transition depending on type of changes
    public var decideViewTransition: DecideViewTransition

    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: @escaping ConfigureSupplementaryView,
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

        self.partialUpdateEvent
            // so in case it does produce a crash, it will be after the data has changed
            .observeOn(MainScheduler.asyncInstance)
            // Collection view has issues digesting fast updates, this should
            // help to alleviate the issues with them.
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                self?.collectionView(event.0, throttledObservedEvent: event.1)
            })
            .disposed(by: disposeBag)
    }

    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var dataSet = false

    private let disposeBag = DisposeBag()

    // This subject and throttle are here
    // because collection view has problems processing animated updates fast.
    // This should somewhat help to alleviate the problem.
    private let partialUpdateEvent = PublishSubject<(UICollectionView, Event<Element>)>()

    /**
     This method exists because collection view updates are throttled because of internal collection view bugs.
     Collection view behaves poorly during fast updates, so this should remedy those issues.
    */
    open func collectionView(_ collectionView: UICollectionView, throttledObservedEvent event: Event<Element>) {
        Binder(self) { dataSource, newSections in
            let oldSections = dataSource.sectionModels
            do {
                // if view is not in view hierarchy, performing batch updates will crash the app
                if collectionView.window == nil {
                    dataSource.setSections(newSections)
                    collectionView.reloadData()
                    return
                }
                let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)

                switch self.decideViewTransition(self, collectionView, differences) {
                case .animated:
                    for difference in differences {
                        dataSource.setSections(difference.finalSections)

                        collectionView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                    }
                case .reload:
                    self.setSections(newSections)
                    collectionView.reloadData()
                case .custom(let actions):
                    self.setSections(newSections)
                    actions(collectionView)
                }
            }
            catch let e {
                #if DEBUG
                    print("Error while binding data animated: \(e)\nFallback to normal `reloadData` behavior.")
                    rxDebugFatalError(e)
                #endif
                self.setSections(newSections)
                collectionView.reloadData()
            }
        }.on(event)
    }

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
                let element = (collectionView, observedEvent)
                dataSource.partialUpdateEvent.on(.next(element))
            }
        }.on(observedEvent)
    }
}
#endif
