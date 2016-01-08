//
//  NumberSection.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/7/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxDataSources

struct NumberSection {
    var header: String

    var numbers: [Int]

    var updated: NSDate

    init(header: String, numbers: [Item], updated: NSDate) {
        self.header = header
        self.numbers = numbers
        self.updated = updated
    }
}

// MARK: Just extensions to say how to determine identity and how to determine is entity updated

extension Int : IdentifiableType {
    public typealias Identity = Int

    public var identity: Int {
        return self
    }
}


extension NumberSection : AnimatableSectionModelType {
    typealias Item = Int
    typealias Identity = String

    var identity: String {
        return header
    }

    var items: [Int] {
        return numbers
    }

    init(original: NumberSection, items: [Item]) {
        self = original
        self.numbers = items
    }
}