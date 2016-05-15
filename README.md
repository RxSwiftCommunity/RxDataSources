Table and Collection view data sources
======================================

## Features

- [x] **O(N)** algorithm for calculating differences
  - the algorithm has the assumption that all sections and items are unique so there is no ambiguity
  - in case there is ambiguity, fallbacks automagically on non animated refresh
- [x] it applies additional heuristics to send the least number of commands to sectioned view
  - even though the running time is linear, preferred number of sent commands is usually a lot less then linear
  - it is preferred (and possible) to cap the number of changes to some small number, and in case the number of changes grows towards linear, just do normal reload
- [x] Supports **extending your item and section structures**
  - just extend your item with `IdentifiableType` and `Equatable`, and your section with `AnimatableSectionModelType`
- [x] Supports all combinations of two level hierarchical animations for **both sections and items**
  - Section animations: Insert, Delete, Move
  - Item animations: Insert, Delete, Move, Reload (if old value is not equal to new value)
- [x] Configurable animation types for `Insert`, `Reload` and `Delete` (Automatic, Fade, ...)
- [x] Example app
- [x] Randomized stress tests (example app)
- [x] Supports editing out of the box (example app)
- [x] Works with `UITableView` and `UICollectionView`

## Why

Writing table and collection view data sources is tedious. There is a large number of delegate methods that need to be implemented for the simplest case possible.

The problem is even bigger when table view or collection view needs to display animated updates.

This project makes it super easy to just write

```swift
Observable.just([MySection(header: "title", items: [1, 2, 3])])
    .bindTo(tableView.rx_itemsWithDataSource(dataSource))
    .addDisposableTo(disposeBag)
```

![RxDataSources example app](https://raw.githubusercontent.com/kzaher/rxswiftcontent/rxdatasources/RxDataSources.gif)

## Installation

**We'll try to keep the API as stable as possible, but breaking API changes can occur.**

### CocoaPods

Podfile
```
pod 'RxDataSources', '~> 0.7'
```

### Carthage

Cartfile
```
github "RxSwiftCommunity/RxDataSources"
```
