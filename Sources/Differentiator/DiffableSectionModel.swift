//
//  DiffableSectionModel.swift
//  
//
//  Created by mlch911 on 2023/5/30.
//

import Foundation

public struct DiffableSectionModel<Section: Hashable, ItemType: Hashable> {
	public var model: Section
	public var items: [Item]
	
	public init(model: Section, items: [Item]) {
		self.model = model
		self.items = items
	}
}

extension DiffableSectionModel: DiffableSectionModelType {
	public typealias Identity = Section
	public typealias Item = ItemType
	
	public var identity: Section {
		return model
	}
}

extension DiffableSectionModel
: CustomStringConvertible {
	
	public var description: String {
		return "\(self.model) > \(items)"
	}
}

extension DiffableSectionModel {
	public init(original: DiffableSectionModel<Section, Item>, items: [Item]) {
		self.model = original.model
		self.items = items
	}
}

extension DiffableSectionModel
: Equatable {
	
	public static func == (lhs: DiffableSectionModel, rhs: DiffableSectionModel) -> Bool {
		return lhs.model == rhs.model
		&& lhs.items == rhs.items
	}
}
