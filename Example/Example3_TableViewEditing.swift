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

// redux like editing example
class EditingExampleViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let sections: [NumberSection] = [NumberSection(header: "Section 1", numbers: [], updated: Date()),
                                         NumberSection(header: "Section 2", numbers: [], updated: Date()),
                                         NumberSection(header: "Section 3", numbers: [], updated: Date())]

        let initialState = SectionedTableViewState(sections: sections)
        let add3ItemsAddStart = Observable.of((), (), ())
        let addCommand = Observable.of(addButton.rx.tap.asObservable(), add3ItemsAddStart)
            .merge()
            .map(TableViewEditingCommand.addRandomItem)

        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableViewEditingCommand.DeleteItem)

        let movedCommand = tableView.rx.itemMoved
            .map(TableViewEditingCommand.MoveItem)

        skinTableViewDataSource(dataSource: dataSource)
        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(initialState) { (state: SectionedTableViewState, command: TableViewEditingCommand) -> SectionedTableViewState in
                return state.execute(command: command)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .shareReplay(1)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
    
    func skinTableViewDataSource(dataSource: RxTableViewSectionedAnimatedDataSource<NumberSection>) {
        
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)
        
        dataSource.configureCell = { (dataSource, table, idxPath, item) in
            let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: idxPath)
            
            cell.textLabel?.text = "\(item)"
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (ds, section) -> String? in
            return ds[section].header
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
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case DeleteItem(IndexPath)
}

// This is the part

struct SectionedTableViewState {
    fileprivate var sections: [NumberSection]
    
    init(sections: [NumberSection]) {
        self.sections = sections
    }
    
    func execute(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = NumberSection(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = NumberSection(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row),
                                        at: moveEvent.destinationIndex.row)
                let destinationSection = NumberSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = NumberSection(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = NumberSection(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

extension TableViewEditingCommand {
    static func addRandomItem() -> TableViewEditingCommand {
        let randSection = Int(arc4random_uniform(UInt32(3)))
        let number = Int(arc4random_uniform(UInt32(100)))
        let item = IntItem(number: number, date: Date())
        return TableViewEditingCommand.AppendItem(item: item, section: randSection)
    }
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
