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

private struct DiffingInput<S> where S: AnimatableSectionModelType {

    let sections: [S]
    let view: UICollectionView
}

private struct DiffingOutput<S> where S: AnimatableSectionModelType {

    let result: DiffingResult<S>
    let view: UICollectionView
}

private enum DiffingResult<S> where S: AnimatableSectionModelType {

    case differences([Changeset<S>], finalSections: [S])
    case error(Error, finalSections: [S])
    case force(finalSections: [S])
}

open class RxCollectionViewSectionedAnimatedDataSource<Section: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<Section>
    , RxCollectionViewDataSourceType {
    public typealias Element = [Section]
    public typealias DecideViewTransition = (CollectionViewSectionedDataSource<Section>, UICollectionView, [Changeset<Section>]) -> ViewTransition
    /// Animation configuration
    public var animationConfiguration: AnimationConfiguration
    /// Calculates differences asynchronously
    public let asyncDiffing: Bool
    /// Calculates view transition depending on type of changes
    public var decideViewTransition: DecideViewTransition
    /// Batch updates should be performed inside UIView.performWithoutAnimation
    public let disableBatchUpdatesAnimation: Bool

    private let disposeBag = DisposeBag()
    private let relayInput = BehaviorRelay<DiffingInput<Section>?>(value: nil)

    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false },
        asyncDiffing: Bool = false,
        disableBatchUpdatesAnimation: Bool = false
        ) {
        self.animationConfiguration = animationConfiguration
        self.asyncDiffing = asyncDiffing
        self.decideViewTransition = decideViewTransition
        self.disableBatchUpdatesAnimation = disableBatchUpdatesAnimation
        super.init(
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView,
            moveItem: moveItem,
            canMoveItemAtIndexPath: canMoveItemAtIndexPath
        )
        self.prepare()
    }

    private func prepare() {
        self.relayInput
            .asObservable()
            .compactMap({ $0 })
            .observeOn(MainScheduler.instance)
            .flatMapLatest({ [weak dataSource = self] (input: DiffingInput<Section>) -> Observable<DiffingOutput<Section>> in
                assert(Thread.isMainThread)
                guard let dataSource = dataSource else {
                    return .never()
                }
                let view = input.view
                guard view.window != nil else {
                    let finalSections = input.sections
                    let result = DiffingResult.force(finalSections: finalSections)
                    let output = DiffingOutput(result: result, view: view)
                    return Observable
                        .just(output, scheduler: MainScheduler.instance)
                }
                let initialSections = dataSource.sectionModels
                let scheduler: ImmediateSchedulerType = {
                    if dataSource.asyncDiffing {
                        return ConcurrentDispatchQueueScheduler(qos: .userInteractive)
                    } else {
                        return MainScheduler.instance
                    }
                }()
                return Observable
                    .just((), scheduler: scheduler)
                    .map({ [asyncDiffing = dataSource.asyncDiffing, finalSections = input.sections] _ -> DiffingResult<Section> in
                        assert(Thread.isMainThread != asyncDiffing)
                        do {
                            let differences = try Diff.differencesForSectionedView(
                                initialSections: initialSections,
                                finalSections: finalSections
                            )
                            return .differences(differences, finalSections: finalSections)
                        } catch let error {
                            return .error(error, finalSections: finalSections)
                        }
                    })
                    .map({ DiffingOutput(result: $0, view: view) })
                    .observeOn(MainScheduler.instance)
            })
            .bind(onNext: { [weak dataSource = self] (output: DiffingOutput<Section>) in
                guard let dataSource = dataSource else {
                    return
                }
                assert(Thread.isMainThread)
                switch output.result {
                case .differences(let differences, finalSections: let finalSections):
                    switch dataSource.decideViewTransition(dataSource, output.view, differences) {
                    case .animated:
                        // each difference must be run in a separate 'performBatchUpdates', otherwise it crashes.
                        // this is a limitation of Diff tool
                        let updates: () -> Void = {
                            for difference in differences {
                                let updateBlock = {
                                    // sections must be set within updateBlock in 'performBatchUpdates'
                                    dataSource.setSections(difference.finalSections)
                                    output.view.batchUpdates(difference, animationConfiguration: dataSource.animationConfiguration)
                                }
                                output.view.performBatchUpdates(updateBlock, completion: nil)
                            }
                        }
                        if dataSource.disableBatchUpdatesAnimation {
                            UIView.performWithoutAnimation(updates)
                        } else {
                            updates()
                        }
                    case .reload:
                        dataSource.setSections(finalSections)
                        output.view.reloadData()
                    }
                case .error(let error, finalSections: let finalSections):
                    rxDebugFatalError(error)
                    dataSource.setSections(finalSections)
                    output.view.reloadData()
                case .force(finalSections: let finalSections):
                    dataSource.setSections(finalSections)
                    output.view.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }

    open func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self, scheduler: MainScheduler.instance, binding: { [view = collectionView] (dataSource, sections: [Section]) in
            let input = DiffingInput(sections: sections, view: view)
            Observable
                .just(input, scheduler: MainScheduler.instance)
                .bind(to: dataSource.relayInput)
                .disposed(by: dataSource.disposeBag)
        }).on(observedEvent)
    }
}
#endif
