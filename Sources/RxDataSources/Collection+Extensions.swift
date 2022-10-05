//
//  Collection+Extensions.swift
//  RxDataSources
//
//  Created by layton on 2022/10/05.
//  Copyright © 2022 kzaher. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import Foundation

extension Collection {
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
#endif
