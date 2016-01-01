Table and Collection view data sources
======================================

This directory contains example implementations of reactive data sources.

Reactive data sources are normal data sources + one additional method

```swift

func view(view: UIXXXView, observedEvent: Event<Element>) {}

```

That means that data sources now have additional responsibility of updating the corresponding view.

## Example usage

```swift
let data: Obserable<Section> = ...

let dataSource = RxTableViewSectionedAnimatedDataSource<Section>()
dataSource.cellFactory = { (tv, ip, i) in
    let cell =tv.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")
    cell.textLabel!.text = "\(i)"
    return cell
}

// animated
data
   .bindTo(animatedTableView.rx_itemsAnimatedWithDataSource(dataSource))
   .addDisposableTo(disposeBag)

// normal reload
data
   .bindTo(tableView.rx_itemsWithDataSource(dataSource))
   .addDisposableTo(disposeBag)
```

## Installation

```
pod 'RxDataSources', '~> 0.1'
```
