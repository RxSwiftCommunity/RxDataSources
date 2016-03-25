//
//  EditingExampleTableViewController.swift
//  RxDataSources
//
//  Created by Segii Shulga on 3/24/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxSwift

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index
            ? self[index]
            : nil
    }
}

class EditingExampleViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        
        let addition = addButton.rx_tap.asObservable()
            .scan(0) { (acum, _) -> Int in
                return acum + 1
            }
            .map { [unowned dataSource] i -> [NumberSection] in
                var section = dataSource.sectionModels[safe:0]
                section?.appendItem(IntItem(number: i, date: NSDate()))
                    
                return [section ?? NumberSection(header: "",
                    numbers: [IntItem(number: i, date: NSDate())],
                    updated: NSDate())]
            }
        
        let deletion = tableView.rx_itemDeleted.asObservable()
            .map { [unowned dataSource] indexPath -> [NumberSection] in
                var section = dataSource.sectionModels[0]
                section.removeItemAtIndex(indexPath.row)
                return [section]
        }
        
        let move = tableView.rx_itemMoved.asObservable()
            .map { moveEvent -> [NumberSection] in
                var section = dataSource.sectionModels[0]
                section.moveItemAtIndex(moveEvent.sourceIndex.row,
                    toIndex: moveEvent.destinationIndex.row)
                return [section]
            }
        
        Observable.of(addition, deletion, move)
            .merge()
            .bindTo(tableView.rx_itemsAnimatedWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        skinTableViewDataSource(dataSource)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
    
    func skinTableViewDataSource(dataSource: RxTableViewSectionedAnimatedDataSource<NumberSection>) {
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .Top,
                                                                   reloadAnimation: .Fade,
                                                                   deleteAnimation: .Left)
        
        dataSource.configureCell = { (dataSource, table, idxPath, item) in
            let cell = table.dequeueReusableCellWithIdentifier("Cell", forIndexPath: idxPath)
            
            cell.textLabel?.text = "\(item)"
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (ds, section) -> String? in
            return ds.sectionAtIndex(section).header
        }
        
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }
    }
}
