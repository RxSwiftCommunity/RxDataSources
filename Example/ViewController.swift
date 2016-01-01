//
//  ViewController.swift
//  Example
//
//  Created by Krunoslav Zaher on 1/1/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import CoreLocation

class NumberCell : UICollectionViewCell {
    @IBOutlet var value: UILabel?
}

class NumberSectionView : UICollectionReusableView {
    @IBOutlet weak var value: UILabel?
}

class ViewController: UIViewController {

    @IBOutlet weak var animatedTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var animatedCollectionView: UICollectionView!
    @IBOutlet weak var refreshButton: UIButton!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let initialRandomizedSections = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: initialValue())

        let ticks = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { _ in () }
        let randomSections = Observable.of(ticks, refreshButton.rx_tap.asObservable())
                .merge()
                .scan(initialRandomizedSections) { a, _ in
                    return a.randomize()
                }
                .map { a in
                    return a.sections
                }
                .shareReplay(1)
        let tvAnimatedDataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let reloadDataSource = RxTableViewSectionedReloadDataSource<NumberSection>()

        skinTableViewDataSource(tvAnimatedDataSource)
        skinTableViewDataSource(reloadDataSource)

        randomSections
            .bindTo(animatedTableView.rx_itemsAnimatedWithDataSource(tvAnimatedDataSource))
            .addDisposableTo(disposeBag)

        randomSections
            .bindTo(tableView.rx_itemsWithDataSource(reloadDataSource))
            .addDisposableTo(disposeBag)

        // Collection view logic works, but when clicking fast because of internal bugs
        // collection view will sometimes get confused. I know what you are thinking,
        // but this is really not a bug in the algorithm. The generated changes are
        // pseudorandom, and crash happens depending on clicking speed.
        //
        // More info in `RxDataSourceStarterKit/README.md`
        //
        // If you want, turn this to true, just click slow :)
        //
        // While `useAnimatedUpdateForCollectionView` is false, you can click as fast as
        // you want, table view doesn't seem to have same issues like collection view.

        let useAnimatedUpdates = false
        if useAnimatedUpdates {
            let cvAnimatedDataSource = RxCollectionViewSectionedAnimatedDataSource<NumberSection>()
            skinCollectionViewDataSource(cvAnimatedDataSource)

            randomSections
                .bindTo(animatedCollectionView.rx_itemsAnimatedWithDataSource(cvAnimatedDataSource))
                .addDisposableTo(disposeBag)
        }
        else {
            let cvReloadDataSource = RxCollectionViewSectionedReloadDataSource<NumberSection>()
            skinCollectionViewDataSource(cvReloadDataSource)
            randomSections
                .bindTo(animatedCollectionView.rx_itemsWithDataSource(cvReloadDataSource))
                .addDisposableTo(disposeBag)
        }

        // touches

        Observable.of(tableView.rx_itemSelected, animatedTableView.rx_itemSelected, animatedCollectionView.rx_itemSelected)
            .merge()
            .withLatestFrom(randomSections) { //(i: NSIndexPath, sections)
                return $1[$0.section].items[$0.item]
            }
            .subscribeNext { item in
                print("Let me guess, it's .... It's \(item), isn't it? Yeah, I've got it.")
            }
            .addDisposableTo(disposeBag)
    }

    // MARK: Skinning

    func skinTableViewDataSource(dataSource: RxTableViewSectionedDataSource<NumberSection>) {
        dataSource.cellFactory = { (tv, ip, i) in
            let cell = tv.dequeueReusableCellWithIdentifier("Cell") ?? UITableViewCell(style:.Default, reuseIdentifier: "Cell")

            cell.textLabel!.text = "\(i)"

            return cell
        }

        dataSource.titleForHeaderInSection = { [unowned dataSource] (section: Int) -> String in
            return dataSource.sectionAtIndex(section).model
        }
    }

    func skinCollectionViewDataSource(dataSource: CollectionViewSectionedDataSource<NumberSection>) {
        dataSource.cellFactory = { (cv, ip, i) in
            let cell = cv.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: ip) as! NumberCell

            cell.value!.text = "\(i)"

            return cell
        }

        dataSource.supplementaryViewFactory = { [unowned dataSource] (cv, kind, ip) in
            let section = cv.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Section", forIndexPath: ip) as! NumberSectionView

            section.value!.text = "\(dataSource.sectionAtIndex(ip.section).model)"
            
            return section
        }
    }

    // MARK: Initial value

    func initialValue() -> [HashableSectionModel<String, Int>] {
        let generate = true
        if generate {
            let nSections = 10
            let nItems = 100

            return (0 ..< nSections).map { (i: Int) -> HashableSectionModel<String, Int> in
                HashableSectionModel(model: "Section \(i + 1)", items: Array(i * nItems ..< (i + 1) * nItems))
            }
        }
        else {
            return _initialValue
        }
    }

    let _initialValue: [HashableSectionModel<String, Int>] = [
        NumberSection(model: "section 1", items: [1, 2, 3]),
        NumberSection(model: "section 2", items: [4, 5, 6]),
        NumberSection(model: "section 3", items: [7, 8, 9]),
        NumberSection(model: "section 4", items: [10, 11, 12]),
        NumberSection(model: "section 5", items: [13, 14, 15]),
        NumberSection(model: "section 6", items: [16, 17, 18]),
        NumberSection(model: "section 7", items: [19, 20, 21]),
        NumberSection(model: "section 8", items: [22, 23, 24]),
        NumberSection(model: "section 9", items: [25, 26, 27]),
        NumberSection(model: "section 10", items: [28, 29, 30])
    ]
}

