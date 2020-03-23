//
//  SectionedDataSourceCommand.swift
//  RxDataSources
//
//  Created by David Weiler-Thiessen on 2020-03-22.
//  Copyright © 2020 Saskatoon Skunkworx. All rights reserved.
//

public enum SectionedDataSourceCommand<Section: IdentifiableSectionModelType> {
	case load(sections: [Section])
	case update(section: Section)
}
