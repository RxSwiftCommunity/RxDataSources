//
//  DiffableSectionModelType.swift
//  
//
//  Created by mlch911 on 2023/5/30.
//

import Foundation

public protocol DiffableSectionModelType: SectionModelType, Hashable where Item: Hashable {}
