# Change Log
All notable changes to this project will be documented in this file.

---

## [0.9](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.8.1)

#### Possibly breaking changes

* Adds default IdentifiableType extensions for:
	* String
	* Int
	* Float

This can break your code if you've implemented those extensions locally. This can be easily solved by just removing local extensions.

#### Features

* Swift 2.3 compatible
* Improves mutability checkes. If data source is being mutated after binding, warning assert is triggered.
* Deprecates `cellFactory` in favor of `configureCell`.
* Improves runtime checks in DEBUG mode for correct `SectionModelType.init` implementation.

#### Fixes

* Fixes default value for `canEditRowAtIndexPath` and sets it to `false`.
* Changes DEBUG asserting behavior in case multiple items with same identity are found to printing warning message to terminal. Fallbacks as before to `reloadData`.

## [0.8.1](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.8.1)

#### Anomalies

* Fixes problem with `SectionModel.init`.

## [0.8](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.8)

#### Features

* Adds new example of how to present heterogeneous sections.

#### Anomalies

* Fixes old `AnimatableSectionModel` definition.
* Fixes problem with `UICollectionView` iOS 9 reordering features.

## [0.7](https://github.com/RxSwiftCommunity/RxDataSources/releases/tag/0.7)

#### Interface changes

* Adds required initializer to `SectionModelType.init(original: Self, items: [Item])` to support moving of table rows with animation.
* `rx_itemsAnimatedWithDataSource` deprecated in favor of just using `rx_itemsWithDataSource`.

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
