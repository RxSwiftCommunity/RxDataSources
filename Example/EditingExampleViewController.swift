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

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}

enum TableViewEditingCommand<T> {
    case AppendItem(item: T, section: Int)
    case MoveItem(sourceIndex: NSIndexPath, destinationIndex: NSIndexPath)
    case DeleteItem(NSIndexPath)
}

struct SectionedTableViewState<T: AnimatableSectionModelType> {
    private var sections: [T]
    
    init(sections: [T]) {
        self.sections = sections
    }
    
    func executeCommand(command: TableViewEditingCommand<T.Item>) -> SectionedTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = T(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.removeAtIndex(indexPath.row)
            sections[indexPath.section] = T(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.removeAtIndex(moveEvent.sourceIndex.row),
                                        atIndex: moveEvent.destinationIndex.row)
                let destinationSection = T(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.removeAtIndex(moveEvent.sourceIndex.row)
                destinationItems.insert(item, atIndex: moveEvent.destinationIndex.row)
                let sourceSection = T(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = T(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

class TableViewEditingCommandsViewModel<T: AnimatableSectionModelType> {
    
    let sectionsChange: Observable<[T]>
    
    init(uiTriggers:(itemAdded: Observable<(item: T.Item, section: Int)>,
        itemDeleted: Observable<NSIndexPath>,
        itemMoved: Observable<ItemMovedEvent>),
         initialData: SectionedTableViewState<T>) {
        
        let addComand = uiTriggers.itemAdded
            .map {
                return TableViewEditingCommand<T.Item>.AppendItem(item: $0.item, section: $0.section)
        }
        let deleteCommand = uiTriggers.itemDeleted
            .map {
                return TableViewEditingCommand<T.Item>.DeleteItem($0)
        }
        let movedCommand = uiTriggers.itemMoved
            .map { (sourceIndex, destinationIndex) -> TableViewEditingCommand<T.Item> in
                return TableViewEditingCommand<T.Item>.MoveItem(sourceIndex: sourceIndex, destinationIndex: destinationIndex)
        }
        
        sectionsChange = Observable.of(addComand, deleteCommand, movedCommand)
            .merge()
            .scan(initialData) {
                return $0.executeCommand($1)
            }
            .map {
                $0.sections
            }
            .shareReplay(1)
    }
}

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
        let initialState = SectionedTableViewState<NumberSection>(sections: sections)
        let itemAdded = addButton.rx_tap
            .scan(0, accumulator: { $0.0 + 1})
            .map { number -> (item: IntItem, section: Int) in
                let randSection = Int(arc4random_uniform(UInt32(sections.count)))
                return (IntItem(number: number, date: NSDate()), randSection)
            }
        let itemDeleted = tableView.rx_itemDeleted.asObservable()
        let itemMoved = tableView.rx_itemMoved.asObservable()
        
        let viewModel = TableViewEditingCommandsViewModel<NumberSection>(uiTriggers: (itemAdded: itemAdded,
            itemDeleted: itemDeleted,
            itemMoved: itemMoved), initialData: initialState)
        
        viewModel.sectionsChange
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
