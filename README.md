Table and Collection view data sources
======================================

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
