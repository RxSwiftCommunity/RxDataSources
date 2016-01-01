//
//  RxCollectionViewSectionedReloadDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

public class RxCollectionViewSectionedReloadDataSource<S: SectionModelType>
    : CollectionViewSectionedDataSource<S>
    , RxCollectionViewDataSourceType {
    
    public typealias Element = [S]

    public override init() {
        super.init()
    }

    public func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .Next(let element):
            setSections(element)
            collectionView.reloadData()
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}