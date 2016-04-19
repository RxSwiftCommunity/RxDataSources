# Change Log
All notable changes to this project will be documented in this file.

---

## [0.7](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.7)

#### Interface changes

* Adds required initializer to `SectionModelType.init(original: Self, items: [Item])` to support moving of table rows with animation.
* `rx_itemsAnimatedWithDataSource` for just using `rx_itemsWithDataSource`.

#### Features

* Adds new example how to use delegates and reactive data sources to customize look.

#### Anomalies

* Fixes problems with moving rows and animated data source.

## [0.6.2](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.6.2)

#### Features

* Xcode 7.3 / Swift 2.2 support

## [0.6.1](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.6.1)

#### Anomalies

* Fixes compilation issues when `DEBUG` is defined.

## [0.6](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.6)

#### Features

* Adds `self` data source as first parameter to all closures. (**breaking change**)
* Adds `AnimationConfiguration` to enable configuring animation.
* Replaces binding error handling logic with `UIBindingObserver`.
