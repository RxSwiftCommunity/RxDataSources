//
//  MultipleSectionModelViewController.swift
//  RxDataSources
//
//  Created by Segii Shulga on 4/26/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

enum MultipleSectionModel {
    case ImageProvidableSection(title: String, items: [ImageSectionItem])
    case ToggleableSection(title: String, items: [ToggleableSectionItem])
    case StepperableSection(title: String, items: [StepperSectionItem])
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .ImageProvidableSection(title: let title, items: _):
            return title
        case .StepperableSection(title: let title, items: _):
            return title
        case .ToggleableSection(title: let title, items: _):
            return title
        }
    }
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = Any
    
    var items: [Item] {
        switch  self {
        case .ImageProvidableSection(title: _, items: let items):
            return items.map {$0}
        case .StepperableSection(title: _, items: let items):
            return items.map {$0}
        case .ToggleableSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    init(original: MultipleSectionModel, items: [Item]) {
        self = original
    }
}

struct ImageSectionItem {
    let image: UIImage
    let title: String
}

struct ToggleableSectionItem {
    let title: String
    let enabled: Bool
}

struct StepperSectionItem {
    let title: String
}

class MultipleSectionModelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sections: [MultipleSectionModel] = [
            .ImageProvidableSection(title: "Section 1",
                items: [ImageSectionItem(image: UIImage(named: "settings")!, title: "General")]),
            .ToggleableSection(title: "Section 2",
                items: [ToggleableSectionItem(title: "On", enabled: true)]),
            .StepperableSection(title: "Section 3",
                items: [StepperSectionItem(title: "1")])
        ]
        
        let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
      Observable.just(sections)
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        skinTableViewDataSource(dataSource)
    }
    
    func skinTableViewDataSource(dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource.sectionAtIndex(idxPath.section) {
            case .ImageProvidableSection(title: _, items: let items):
                let item = items[idxPath.row]
                let cell: ImageTitleTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = item.title
                cell.cellImageView.image = item.image
                
                return cell
            case .StepperableSection(title: _, items: let items):
                let item = items[idxPath.row]
                let cell: TitleSteperTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = item.title
                
                return cell
            case .ToggleableSection(title: _, items: let items):
                let item = items[idxPath.row]
                let cell: TitleSwitchTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.switchControl.on = item.enabled
                cell.titleLabel.text = item.title
                
                return cell
            }
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource.sectionAtIndex(index)
            
            return section.title
        }
    }
    
}
