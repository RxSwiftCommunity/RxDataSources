//
//  SectionedDataSourceCommand.swift
//  RxDataSources
//
//  Created by David Weiler-Thiessen on 2020-03-22.
//  Copyright © 2020 Saskatoon Skunkworx. All rights reserved.
//

public enum SectionedDataSourceCommand<Section: IdentifiableSectionModelType> {
	case append(section: Section)
	case insert(section: Section, at: Section.Identity)
	case load(sections: [Section])
	case remove(section: Section.Identity)
	case update(section: Section)
}
