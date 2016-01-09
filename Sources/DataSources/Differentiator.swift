//
//  Differentiator.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public enum DifferentiatorError
    : ErrorType
    , CustomDebugStringConvertible {
    case DuplicateItem(item: Any)
}

extension DifferentiatorError {
    public var debugDescription: String {
        switch self {
        case let .DuplicateItem(item):
            return "Duplicate item \(item)"
        }
    }
}

enum EditEvent : CustomDebugStringConvertible {
    case Inserted           // can't be found in old sections
    case Deleted            // Was in old, not in new, in it's place is something "not new" :(, otherwise it's Updated
    case Moved              // same item, but was on different index, and needs explicit move
    case MovedAutomatically // don't need to specify any changes for those rows
    case Untouched
}

extension EditEvent {
    var debugDescription: String {
        get {
            switch self {
            case .Inserted:
                return "Inserted"
            case .Deleted:
                return "Deleted"
            case .Moved:
                return "Moved"
            case .MovedAutomatically:
                return "MovedAutomatically"
            case .Untouched:
                return "Untouched"
            }
        }
    }
}

struct SectionAssociatedData {
    var event: EditEvent
    var indexAfterDelete: Int?
}

extension SectionAssociatedData : CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            return "\(event), \(indexAfterDelete)"
        }
    }
}

struct ItemAssociatedData {
    var event: EditEvent
    var indexAfterDelete: Int?
    var finalIndex: ItemPath?
}

extension ItemAssociatedData : CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            return "\(event) \(indexAfterDelete)"
        }
    }
}

extension ItemAssociatedData {
    static var initial : ItemAssociatedData {
        return ItemAssociatedData(event: .Untouched, indexAfterDelete: nil, finalIndex: nil)
    }
}

func indexSections<S: AnimatableSectionModelType>(sections: [S]) throws -> [S.Identity : Int] {
    var indexedSections: [S.Identity : Int] = [:]
    for (i, section) in sections.enumerate() {
        guard indexedSections[section.identity] == nil else {
            #if DEBUG
            precondition(indexedSections[section.identity] == nil, "Section \(section) has already been indexed at \(indexedSections[section]!)")
            #endif
            throw DifferentiatorError.DuplicateItem(item: section)
        }
        indexedSections[section.identity] = i
    }
    
    return indexedSections
}

func indexSectionItems<S: AnimatableSectionModelType>(sections: [S]) throws -> [S.Item.Identity : (Int, Int)] {
    var totalItems = 0
    for i in 0 ..< sections.count {
        totalItems += sections[i].items.count
    }
    
    // let's make sure it's enough
    var indexedItems: [S.Item.Identity : (Int, Int)] = Dictionary(minimumCapacity: totalItems * 3)
    
    for i in 0 ..< sections.count {
        for (j, item) in sections[i].items.enumerate() {
            guard indexedItems[item.identity] == nil else {
                #if DEBUG
                precondition(indexedItems[item.identity] == nil, "Item \(item) has already been indexed at \(indexedItems[item]!)" )
                #endif
                throw DifferentiatorError.DuplicateItem(item: item)
            }
            indexedItems[item.identity] = (i, j)
        }
    }
    
    return indexedItems
}


/*

I've uncovered this case during random stress testing of logic.
This is the hardest generic update case that causes two passes, first delete, and then move/insert

[
NumberSection(model: "1", items: [1111]),
NumberSection(model: "2", items: [2222]),
]

[
NumberSection(model: "2", items: [0]),
NumberSection(model: "1", items: []),
]

If update is in the form

* Move section from 2 to 1
* Delete Items at paths 0 - 0, 1 - 0
* Insert Items at paths 0 - 0

or

* Move section from 2 to 1
* Delete Items at paths 0 - 0
* Reload Items at paths 1 - 0

or

* Move section from 2 to 1
* Delete Items at paths 0 - 0
* Reload Items at paths 0 - 0

it crashes table view.

No matter what change is performed, it fails for me.
If anyone knows how to make this work for one Changeset, PR is welcome.

*/

// If you are considering working out your own algorithm, these are tricky
// transition cases that you can use.

// case 1
/*
from = [
    NumberSection(model: "section 4", items: [10, 11, 12]),
    NumberSection(model: "section 9", items: [25, 26, 27]),
]
to = [
    HashableSectionModel(model: "section 9", items: [11, 26, 27]),
    HashableSectionModel(model: "section 4", items: [10, 12])
]
*/

// case 2
/*
from = [
    HashableSectionModel(model: "section 10", items: [26]),
    HashableSectionModel(model: "section 7", items: [5, 29]),
    HashableSectionModel(model: "section 1", items: [14]),
    HashableSectionModel(model: "section 5", items: [16]),
    HashableSectionModel(model: "section 4", items: []),
    HashableSectionModel(model: "section 8", items: [3, 15, 19, 23]),
    HashableSectionModel(model: "section 3", items: [20])
]
to = [
    HashableSectionModel(model: "section 10", items: [26]),
    HashableSectionModel(model: "section 1", items: [14]),
    HashableSectionModel(model: "section 9", items: [3]),
    HashableSectionModel(model: "section 5", items: [16, 8]),
    HashableSectionModel(model: "section 8", items: [15, 19, 23]),
    HashableSectionModel(model: "section 3", items: [20]),
    HashableSectionModel(model: "Section 2", items: [7])
]
*/

// case 3
/*
from = [
    HashableSectionModel(model: "section 4", items: [5]),
    HashableSectionModel(model: "section 6", items: [20, 14]),
    HashableSectionModel(model: "section 9", items: []),
    HashableSectionModel(model: "section 2", items: [2, 26]),
    HashableSectionModel(model: "section 8", items: [23]),
    HashableSectionModel(model: "section 10", items: [8, 18, 13]),
    HashableSectionModel(model: "section 1", items: [28, 25, 6, 11, 10, 29, 24, 7, 19])
]
to = [
    HashableSectionModel(model: "section 4", items: [5]),
    HashableSectionModel(model: "section 6", items: [20, 14]),
    HashableSectionModel(model: "section 9", items: [16]),
    HashableSectionModel(model: "section 7", items: [17, 15, 4]),
    HashableSectionModel(model: "section 2", items: [2, 26, 23]),
    HashableSectionModel(model: "section 8", items: []),
    HashableSectionModel(model: "section 10", items: [8, 18, 13]),
    HashableSectionModel(model: "section 1", items: [28, 25, 6, 11, 10, 29, 24, 7, 19])
]
*/

// Generates differential changes suitable for sectioned view consumption.
// It will not only detect changes between two states, but it will also try to compress those changes into
// almost minimal set of changes.
//
// I know, I know, it's ugly :( Totally agree, but this is the only general way I could find that works 100%, and
// avoids UITableView quirks.
//
// Please take into consideration that I was also convinced about 20 times that I've found a simple general
// solution, but then UITableView falls apart under stress testing :(
//
// Sincerely, if somebody else would present me this 250 lines of code, I would call him a mad man. I would think
// that there has to be a simpler solution. Well, after 3 days, I'm not convinced any more :)
//
// Maybe it can be made somewhat simpler, but don't think it can be made much simpler.
//
// The algorithm could take anywhere from 1 to 3 table view transactions to finish the updates.
//
//  * stage 1 - remove deleted sections and items
//  * stage 2 - move sections into place
//  * stage 3 - fix moved and new items
//
// There maybe exists a better division, but time will tell.
//
public func differencesForSectionedView<S: AnimatableSectionModelType>(
        initialSections: [S],
        finalSections: [S]
    )
    throws -> [Changeset<S>] {
    typealias I = S.Item

    var result: [Changeset<S>] = []

    var sectionCommands = try CommandGenerator<S>.generatorForInitialSections(initialSections, finalSections: finalSections)

    result.appendContentsOf(sectionCommands.generateDeleteSections())
    result.appendContentsOf(try sectionCommands.generateInsertAndMoveSections())
    result.appendContentsOf(try sectionCommands.generateNewAndMovedItems())

    return result
}

struct CommandGenerator<S: AnimatableSectionModelType> {
    let initialSections: [S]
    let finalSections: [S]

    // first pass
    let deletedSections: [Int]

    // second pass
    let movedSections: [(from: Int, to: Int)]
    let insertedSections: [Int]

    let initialItemIndexes: [S.Item.Identity : (Int, Int)]
    let finalItemIndexes: [S.Item.Identity : (Int, Int)]

    var initialSectionData: [SectionAssociatedData]
    var finalSectionData: [SectionAssociatedData]

    let initialSectionIndexes: [S.Identity : Int]
    let finalSectionIndexes: [S.Identity : Int]

    var initialItemData: [[ItemAssociatedData]]
    var finalItemData: [[ItemAssociatedData]]

    static func generatorForInitialSections<S: AnimatableSectionModelType>(
        initialSections: [S],
        finalSections: [S]
    ) throws -> CommandGenerator<S> {

        let initialSectionIndexes = try indexSections(initialSections)
        let finalSectionIndexes = try indexSections(finalSections)

        var movedSections = [(from: Int, to: Int)]()
        var insertedSections = [Int]()
        var deletedSections = [Int]()

        var initialSectionData = [SectionAssociatedData](count: initialSections.count, repeatedValue: SectionAssociatedData(event: .Untouched,  indexAfterDelete: nil))
        var finalSectionData = [SectionAssociatedData](count: finalSections.count, repeatedValue: SectionAssociatedData(event: .Untouched, indexAfterDelete: nil))

        _ = {
            // mark deleted sections {
            // 1rst stage
            var sectionIndexAfterDelete = 0
            for (i, initialSection) in initialSections.enumerate() {
                if finalSectionIndexes[initialSection.identity] == nil {
                    initialSectionData[i].event = .Deleted
                    deletedSections.append(i)
                }
                else {
                    initialSectionData[i].indexAfterDelete = sectionIndexAfterDelete
                    sectionIndexAfterDelete += 1
                }
            }
        }()
        
        // }

        _ = try {
            var untouchedOldIndex: Int? = 0
            let findNextUntouchedOldIndex = { (initialSearchIndex: Int?) -> Int? in
                var i = initialSearchIndex
                
                while i != nil && i < initialSections.count {
                    if initialSectionData[try i.unwrap()].event == .Untouched {
                        return i
                    }
                    
                    i = try i.unwrap() + 1
                }
                
                return nil
            }
            
            // inserted and moved sections {
            // this should fix all sections and move them into correct places
            // 2nd stage
            for (i, finalSection) in finalSections.enumerate() {
                untouchedOldIndex = try findNextUntouchedOldIndex(untouchedOldIndex)
                
                // oh, it did exist
                if let oldSectionIndex = initialSectionIndexes[finalSection.identity] {
                    let moveType = oldSectionIndex != untouchedOldIndex ? EditEvent.Moved : EditEvent.MovedAutomatically
                    
                    finalSectionData[i].event = moveType
                    initialSectionData[oldSectionIndex].event = moveType
                    
                    if moveType == .Moved {
                        let moveCommand = (from: try initialSectionData[oldSectionIndex].indexAfterDelete.unwrap(), to: i)
                        movedSections.append(moveCommand)
                    }
                }
                else {
                    finalSectionData[i].event = .Inserted
                    insertedSections.append(i)
                }
            }
        }()

        let initialItemData = initialSections.map { s in
            return [ItemAssociatedData](count: s.items.count, repeatedValue: ItemAssociatedData.initial)
        }

        let finalItemData = finalSections.map { s in
            return [ItemAssociatedData](count: s.items.count, repeatedValue: ItemAssociatedData.initial)
        }

        return CommandGenerator<S>(
            initialSections: initialSections,
            finalSections: finalSections,

            deletedSections: deletedSections,

            movedSections: movedSections,
            insertedSections: insertedSections,

            initialItemIndexes: try indexSectionItems(initialSections),
            finalItemIndexes:  try indexSectionItems(finalSections),

            initialSectionData: initialSectionData,
            finalSectionData: finalSectionData,

            initialSectionIndexes: initialSectionIndexes,
            finalSectionIndexes: finalSectionIndexes,

            initialItemData: initialItemData,
            finalItemData: finalItemData
        )
    }

    mutating func generateDeleteSections() -> [Changeset<S>] {
        var deletedItems = [ItemPath]()
        var updatedItems = [ItemPath]()

        // mark deleted items {
        // 1rst stage again (I know, I know ...)
        for (i, initialSection) in initialSections.enumerate() {
            let event = initialSectionData[i].event

            // Deleted section will take care of deleting child items.
            // In case of moving an item from deleted section, tableview will
            // crash anyway, so this is not limiting anything.
            if event == .Deleted {
                continue
            }

            var indexAfterDelete = 0
            for (j, initialItem) in initialSection.items.enumerate() {
                if let finalItemIndex = finalItemIndexes[initialItem.identity] {
                    let targetSectionEvent = finalSectionData[finalItemIndex.0].event
                    // In case there is move of item from existing section into new section
                    // that is also considered a "delete"
                    if targetSectionEvent == .Inserted {
                        self.initialItemData[i][j].event = .Deleted
                        deletedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                        continue
                    }

                    initialItemData[i][j].indexAfterDelete = indexAfterDelete
                    initialItemData[i][j].finalIndex = ItemPath(sectionIndex: finalItemIndex.0, itemIndex: finalItemIndex.1)
                    indexAfterDelete += 1

                    // should this item be reloaded, if so, then this is the time to do it

                    let finalItem = finalSections[finalItemIndex.0].items[finalItemIndex.1]
                    if finalItem != initialItem {
                        updatedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                    }
                }
                else {
                    initialItemData[i][j].event = .Deleted
                    deletedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                }
            }

        }
        // }

        if deletedItems.count == 0 && deletedSections.count == 0 && updatedItems.count == 0 {
            return []
        }

        let finalSectionsAfterDeletes = initialSections.enumerate().flatMap { i, s -> [S] in
            if self.initialSectionData[i].event == .Deleted {
                return []
            }

            var items: [S.Item] = []
            for (j, _) in s.items.enumerate() {
                if let finalIndex = self.initialItemData[i][j].finalIndex {
                    items.append(self.finalSections[finalIndex.sectionIndex].items[finalIndex.itemIndex])
                }
            }
            return [S(original: s, items: items)]
        }
        return [Changeset(
            finalSections: finalSectionsAfterDeletes,
            deletedSections: deletedSections,
            deletedItems: deletedItems,
            updatedItems: updatedItems
        )]
    }

    func generateInsertAndMoveSections() throws -> [Changeset<S>] {
        if insertedSections.count ==  0 && movedSections.count == 0 /*&& newAndMovedSections_updatedSections.count != 0*/ {
            return []
        }

        // sections should be in place, but items should be original without deleted ones
        let finalSections: [S] = try self.finalSections.enumerate().map { i, s -> S in
            let event = self.finalSectionData[i].event
            
            if event == .Inserted {
                // it's already set up
                return s
            }
            else if event == .Moved || event == .MovedAutomatically {
                let originalSectionIndex = try initialSectionIndexes[s.identity].unwrap()
                let originalSection = initialSections[originalSectionIndex]
                
                var items: [S.Item] = []
                for (j, _) in originalSection.items.enumerate() {
                    let initialData = self.initialItemData[originalSectionIndex][j]

                    guard initialData.event != .Deleted else {
                        continue
                    }

                    guard let finalIndex = initialData.finalIndex else {
                        try rxPrecondition(false, "Item was moved, but no final location.")
                        continue
                    }

                    items.append(self.finalSections[finalIndex.sectionIndex].items[finalIndex.itemIndex])
                }
                
                return S(original: s, items: items)
            }
            else {
                try rxPrecondition(false, "This is weird, this shouldn't happen")
                return s
            }
        }

        return [Changeset(
            finalSections: finalSections,
            insertedSections:  insertedSections,
            movedSections: movedSections
        )]
    }

    mutating func generateNewAndMovedItems() throws -> [Changeset<S>] {
        var insertedItems = [ItemPath]()
        var movedItems = [(from: ItemPath, to: ItemPath)]()

        // mark new and moved items {
        // 3rd stage
        for (i, _) in finalSections.enumerate() {
            let finalSection = finalSections[i]
            
            let originalSection: Int? = initialSectionIndexes[finalSection.identity]
            
            var untouchedOldIndex: Int? = 0
            let findNextUntouchedOldIndex = { (initialSearchIndex: Int?) -> Int? in
                var i2 = initialSearchIndex

                guard let originalSection = originalSection else {
                    return nil
                }
                while i2 != nil && i2 ?? Int.max < self.initialItemData[originalSection].count {
                    let i2Value = try i2.unwrap()

                    if self.initialItemData[originalSection][i2Value].event == .Untouched {
                        return i2
                    }
                    
                    i2 = i2Value + 1
                }
                
                return nil
            }
            
            let sectionEvent = finalSectionData[i].event
            // new and deleted sections cause reload automatically
            if sectionEvent != .Moved && sectionEvent != .MovedAutomatically {
                continue
            }
            
            for (j, finalItem) in finalSection.items.enumerate() {
                let currentItemEvent = finalItemData[i][j].event
                
                try rxPrecondition(currentItemEvent == .Untouched, "Current event is not untouched")
                
                untouchedOldIndex = try findNextUntouchedOldIndex(untouchedOldIndex)
                
                // ok, so it was moved from somewhere
                if let originalIndex = initialItemIndexes[finalItem.identity] {
                    
                    // In case trying to move from deleted section, abort, otherwise it will crash table view
                    if initialSectionData[originalIndex.0].event == .Deleted {
                        finalItemData[i][j].event = .Inserted
                        insertedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                    }
                    // original section can't be inserted
                    else if initialSectionData[originalIndex.0].event == .Inserted {
                        try rxPrecondition(false, "New section in initial sections, that is wrong")
                    }
                    // what's left is moved section
                    else {
                        try rxPrecondition(initialSectionData[originalIndex.0].event == .Moved || initialSectionData[originalIndex.0].event == .MovedAutomatically, "Section not moved")
                        
                        let eventType =
                               originalIndex.0 == (originalSection ?? -1)
                            && originalIndex.1 == (untouchedOldIndex ?? -1)
                            
                            ? EditEvent.MovedAutomatically : EditEvent.Moved
                        
                        // print("\(finalItem) \(eventType) \(originalIndex), \(originalSection) \(untouchedOldIndex)")
                        
                        initialItemData[originalIndex.0][originalIndex.1].event = eventType
                        finalItemData[i][j].event = eventType

                        if eventType == .Moved {
                            let finalSectionIndex = try finalSectionIndexes[initialSections[originalIndex.0].identity].unwrap()
                            let moveFromItemWithIndex = try initialItemData[originalIndex.0][originalIndex.1].indexAfterDelete.unwrap()

                            let moveCommand = (
                                from: ItemPath(sectionIndex: finalSectionIndex, itemIndex: moveFromItemWithIndex),
                                to: ItemPath(sectionIndex: i, itemIndex: j)
                            )
                            movedItems.append(moveCommand)
                        }
                        else if eventType == .MovedAutomatically {
                        }
                        else {
                            try rxPrecondition(false, "No third option")
                        }
                    }
                }
                // if it wasn't moved from anywhere, it's inserted
                else {
                    finalItemData[i][j].event = .Inserted
                    insertedItems.append(ItemPath(sectionIndex: i, itemIndex: j))
                }
            }
        }
        // }

        if insertedItems.count == 0 && movedItems.count == 0 {
            return []
        }
        return [Changeset(
            finalSections: finalSections,
            insertedItems: insertedItems,
            movedItems: movedItems
        )]
    }
}