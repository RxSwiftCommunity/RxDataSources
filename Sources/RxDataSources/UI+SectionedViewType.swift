//
//  UI+SectionedViewType.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit
import Differentiator

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension UITableView : AnimatedSectionedViewType {
  
    public typealias Animation = UITableView.RowAnimation
    
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animation: Animation) {
        self.insertRows(at: paths, with: animation)
    }
    
    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animation: Animation) {
        self.deleteRows(at: paths, with: animation)
    }
    
    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }
    
    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animation: Animation) {
        self.reloadRows(at: paths, with: animation)
    }
    
    public func insertSections(_ sections: [Int], animation: Animation) {
        self.insertSections(indexSet(sections), with: animation)
    }
    
    public func deleteSections(_ sections: [Int], animation: Animation) {
        self.deleteSections(indexSet(sections), with: animation)
    }
    
    public func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(_ sections: [Int], animation: Animation) {
        self.reloadSections(indexSet(sections), with: animation)
    }
}

extension UICollectionView : SectionedViewType {
    public func insertItemsAtIndexPaths(_ paths: [IndexPath]) {
        self.insertItems(at: paths)
    }
    
    public func deleteItemsAtIndexPaths(_ paths: [IndexPath]) {
        self.deleteItems(at: paths)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveItem(at: from, to: to)
    }
    
    public func reloadItemsAtIndexPaths(_ paths: [IndexPath]) {
        self.reloadItems(at: paths)
    }
    
    public func insertSections(_ sections: [Int]) {
        self.insertSections(indexSet(sections))
    }
    
    public func deleteSections(_ sections: [Int]) {
        self.deleteSections(indexSet(sections))
    }
    
    public func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(_ sections: [Int]) {
        self.reloadSections(indexSet(sections))
    }
}

public protocol SectionedViewType {
    func insertItemsAtIndexPaths(_ paths: [IndexPath])
    func deleteItemsAtIndexPaths(_ paths: [IndexPath])
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(_ paths: [IndexPath])
    
    func insertSections(_ sections: [Int])
    func deleteSections(_ sections: [Int])
    func moveSection(_ from: Int, to: Int)
    func reloadSections(_ sections: [Int])
}
    
public protocol AnimatedSectionedViewType {
    
    associatedtype Animation
    
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animation: Animation)
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animation: Animation)
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animation: Animation)
    
    func insertSections(_ sections: [Int], animation: Animation)
    func deleteSections(_ sections: [Int], animation: Animation)
    func moveSection(_ from: Int, to: Int)
    func reloadSections(_ sections: [Int], animation: Animation)
}

extension SectionedViewType {

    public func batchUpdates<Section>(_ changes: Changeset<Section>) {
        _batchUpdates(changes: changes, deleteSections: { deletedSections in
            self.deleteSections(deletedSections)
        }, insertSections: { insertedSections in
            self.insertSections(insertedSections)
        }, moveSection: { from, to in
            self.moveSection(from, to: to)
        }, deleteItems: { deletedItems in
            self.deleteItemsAtIndexPaths(deletedItems)
        }, insertItems: { insertedItems in
            self.insertItemsAtIndexPaths(insertedItems)
        }, updateItems: { updatedItems in
            self.reloadItemsAtIndexPaths(updatedItems)
        }, moveItem: { from, to in
            self.moveItemAtIndexPath(from, to: to)
        })
    }
}

extension AnimatedSectionedViewType {

    public func batchUpdates<Section>(_ changes: Changeset<Section>, animationConfiguration: AnimationConfiguration<Animation>) {
        _batchUpdates(changes: changes, deleteSections: { deletedSections in
            self.deleteSections(deletedSections, animation: animationConfiguration.deleteAnimation)
        }, insertSections: { insertedSections in
            self.insertSections(insertedSections, animation: animationConfiguration.insertAnimation)
        }, moveSection: { from, to in
            self.moveSection(from, to: to)
        }, deleteItems: { deletedItems in
            self.deleteItemsAtIndexPaths(deletedItems, animation: animationConfiguration.deleteAnimation)
        }, insertItems: { insertedItems in
            self.insertItemsAtIndexPaths(insertedItems, animation: animationConfiguration.insertAnimation)
        }, updateItems: { updatedItems in
            self.reloadItemsAtIndexPaths(updatedItems, animation: animationConfiguration.reloadAnimation)
        }, moveItem: { from, to in
            self.moveItemAtIndexPath(from, to: to)
        })
    }
}

private typealias SectionChanges = ([Int]) -> Void
private typealias ItemChanges = ([IndexPath]) -> Void

private func _batchUpdates<S>(
    changes: Changeset<S>,
    deleteSections: SectionChanges, insertSections: SectionChanges, moveSection:(Int, Int) -> Void,
    deleteItems: ItemChanges, insertItems: ItemChanges, updateItems: ItemChanges, moveItem: (IndexPath, IndexPath) -> Void
) {
    deleteSections(changes.deletedSections)
    
    insertSections(changes.insertedSections)
    for (from, to) in changes.movedSections {
        moveSection(from, to)
    }
    
    deleteItems(changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) })
    insertItems(changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) })
    updateItems(changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) })
    
    for (from, to) in changes.movedItems {
        moveItem(IndexPath(item: from.itemIndex, section: from.sectionIndex), IndexPath(item: to.itemIndex, section: to.sectionIndex))
    }
}
#endif
