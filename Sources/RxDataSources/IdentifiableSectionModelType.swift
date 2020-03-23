//
//  IdentifiableSectionModelType.swift
//  RxDataSources
//
//  Created by David Weiler-Thiessen on 2020-03-22.
//  Copyright © 2020 Saskatoon Skunkworx. All rights reserved.
//

public protocol IdentifiableSectionModelType
	: SectionModelType
	, IdentifiableType where Item: IdentifiableType {
}
