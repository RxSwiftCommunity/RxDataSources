//
//  IntegerType+IdentifiableType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/4/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension BinaryInteger {
    typealias identity = Self

    public var identity: Self {
        return self
    }
}

extension Swift.Int : Differentiator.IdentifiableType {

}

extension Swift.Int8 : Differentiator.IdentifiableType {

}

extension Swift.Int16 : Differentiator.IdentifiableType {

}

extension Swift.Int32 : Differentiator.IdentifiableType {

}

extension Swift.Int64 : Differentiator.IdentifiableType {

}


extension Swift.UInt : Differentiator.IdentifiableType {

}

extension Swift.UInt8 : Differentiator.IdentifiableType {

}

extension Swift.UInt16 : Differentiator.IdentifiableType {

}

extension Swift.UInt32 : Differentiator.IdentifiableType {

}

extension Swift.UInt64 : Differentiator.IdentifiableType {

}

