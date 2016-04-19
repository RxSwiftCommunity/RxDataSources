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
import RxCocoa

class EditingExampleViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let sections: [NumberSection] = [NumberSection(header: "Section 1", numbers: [], updated: NSDate()),
                                         NumberSection(header: "Section 2", numbers: [], updated: NSDate()),
                                         NumberSection(header: "Section 3", numbers: [], updated: NSDate())]

        let initialState = SectionedTableViewState(sections: sections)
        let addCommand = Observable.of(addButton.rx_tap.asObservable(), Observable.of((), (), ()))
            .merge()
            .scan(0) { x, _ in x + 1 }
            .map { (number: Int) -> TableViewEditingCommand in
                let randSection = Int(arc4random_uniform(UInt32(sections.count)))
                let item = IntItem(number: number, date: NSDate())
                return TableViewEditingCommand.AppendItem(item: item, section: randSection)
            }
        let deleteCommand = tableView.rx_itemDeleted.asObservable()
            .map {
                return TableViewEditingCommand.DeleteItem($0)
            }
        let movedCommand = tableView.rx_itemMoved
            .map { (sourceIndex, destinationIndex) in
                return TableViewEditingCommand.MoveItem(sourceIndex: sourceIndex, destinationIndex: destinationIndex)
            }

        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(initialState) {
                return $0.executeCommand($1)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .shareReplay(1)
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
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

enum TableViewEditingCommand {
    case AppendItem(item: IntItem, section: Int)
    case MoveItem(sourceIndex: NSIndexPath, destinationIndex: NSIndexPath)
    case DeleteItem(NSIndexPath)
}

// This is the part

struct SectionedTableViewState {
    private var sections: [NumberSection]
    
    init(sections: [NumberSection]) {
        self.sections = sections
    }
    
    func executeCommand(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = NumberSection(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.removeAtIndex(indexPath.row)
            sections[indexPath.section] = NumberSection(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.removeAtIndex(moveEvent.sourceIndex.row),
                                        atIndex: moveEvent.destinationIndex.row)
                let destinationSection = NumberSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.removeAtIndex(moveEvent.sourceIndex.row)
                destinationItems.insert(item, atIndex: moveEvent.destinationIndex.row)
                let sourceSection = NumberSection(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = NumberSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
