//
//  FloatingPointType+IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension FloatingPoint {
    typealias identity = Self

    public var identity: Self {
        return self
    }
}

extension Swift.Float : Differentiator.IdentifiableType {

}

extension Swift.Double : Differentiator.IdentifiableType {

}
