Table and Collection view data sources
======================================

## Why

Writing table and collection view data sources is tedious. There is a large number of delegate methods that need to be implemented for the simplest case possible.

The problem is even bigger when table view or collection view needs to display animated updates.

This project makes it super easy to just write

```swift
dataSequence
    .bindTo(tableView.rx_itemsWithDataSource(dataSource))
    .addDisposableTo(disposeBag)
```

where data source is defined as

```
let dataSource = RxTableViewSectionedReloadDataSource<MySection>()
dataSource.cellFactory = { (tv, ip, i) in
    let cell = tv.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")
    cell.textLabel!.text = "\(i)"
    return cell
}
```

### Animated table and collection view updates

**For the animated data sources to be able to detect identity and changes of objects, your section needs to conform to `AnimatableSectionModelType` or you can just use `AnimatableSectionModel`. Demonstration how to use them and implement `AnimatableSectionModelType` is contained inside the Example app.**

In case you want to use animated data sources, just replace

`let dataSource = RxTableViewSectionedReloadDataSource<MySection>()` with <br/>`let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>()`

and

` .bindTo(tableView.rx_itemsWithDataSource(dataSource))` with <br/> `.bindTo(tableView.rx_itemsAnimatedWithDataSource(dataSource)) `

## Installation

**We'll try to keep the API as stable as possible, but breaking API changes can occur.**

### CocoaPods

Podfile
```
pod 'RxDataSources', '~> 0.4'
```

### Carthage

Cartfile
```
github "RxSwiftCommunity/RxDataSources"
```
