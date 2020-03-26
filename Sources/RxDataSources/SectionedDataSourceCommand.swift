//
//  SectionedDataSourceCommand.swift
//  RxDataSources
//
//  Created by David Weiler-Thiessen on 2020-03-22.
//  Copyright © 2020 Saskatoon Skunkworx. All rights reserved.
//

public enum SectionedDataSourceCommand<Section: IdentifiableSectionModelType> {
	case add(section: Section, after: Section.Identity)
	case load(sections: [Section])
	case remove(section: Section.Identity)
	case update(section: Section)
}
