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
    
    var error: Error? {
        switch self {
        case .error(let error, finalSections: _):
            return error
        default:
            return nil
        }
    }
    
    var finalSections: [S] {
        switch self {
        case .differences(_, finalSections: let finalSections):
            return finalSections
        case .error(_, finalSections: let finalSections):
            return finalSections
        case .force(finalSections: let finalSections):
            return finalSections
        }
    }
}

private struct DiffingReducer<S> where S: AnimatableSectionModelType {
    
    let finalSections: [S]
    let force: Bool
    let initialSections: [S]
    let view: UICollectionView
    
    init(finalSections: [S], force: Bool, initialSections: [S], view: UICollectionView) {
        self.finalSections = finalSections
        self.force = force
        self.initialSections = initialSections
        self.view = view
    }
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
        let scheduler: ImmediateSchedulerType = {
            if self.asyncDiffing {
                let queue = DispatchQueue(label: UUID().uuidString, qos: .userInteractive)
                return SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: UUID().uuidString)
            } else {
                return MainScheduler.instance
            }
        }()
        self.relayInput
            .asObservable()
            .observeOn(scheduler)
            .compactMap({ $0 })
            .scan(nil, accumulator: { (reducer, input) -> DiffingReducer<Section> in
                let finalSections = input.sections
                let force = input.view !== reducer?.view || reducer?.finalSections.isEmpty ?? true
                let initialSections = reducer?.finalSections ?? []
                let view = input.view
                return DiffingReducer(finalSections: finalSections, force: force, initialSections: initialSections, view: view)
            })
            .compactMap({ $0 })
            .concatMap({ (reducer: DiffingReducer<Section>) -> Observable<DiffingOutput<Section>> in
                return Observable<DiffingOutput<Section>>
                    .create({ (observer: AnyObserver<DiffingOutput<Section>>) -> Disposable in
                        defer {
                            let result: DiffingResult<Section> = {
                                guard reducer.force == false else {
                                    return .force(finalSections: reducer.finalSections)
                                }
                                do {
                                    let differences = try Diff.differencesForSectionedView(
                                        initialSections: reducer.initialSections,
                                        finalSections: reducer.finalSections
                                    )
                                    return .differences(differences, finalSections: reducer.finalSections)
                                } catch let error {
                                    return .error(error, finalSections: reducer.finalSections)
                                }
                            }()
                            let view = reducer.view
                            let output = DiffingOutput(result: result, view: view)
                            observer.onNext(output)
                            observer.onCompleted()
                        }
                        return Disposables.create()
                    })
            })
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak dataSource = self] (output: DiffingOutput<Section>) in
                guard let dataSource = dataSource else {
                    return
                }
                switch output.result {
                case .differences(let differences, finalSections: let finalSections) where output.view.window != nil:
                    switch dataSource.decideViewTransition(dataSource, output.view, differences) {
                    case .animated:
                        let updates: () -> Void = {
                            for difference in differences {
                                let updateBlock = {
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
                default:
                    if let error = output.result.error {
                        rxDebugFatalError(error)
                    }
                    dataSource.setSections(output.result.finalSections)
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
