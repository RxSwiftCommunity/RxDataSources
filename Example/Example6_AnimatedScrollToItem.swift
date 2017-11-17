//
//  Example6_AnimatedScrollToItem.swift
//  RxDataSources
//
//  Created by Jakub Turek on 17/11/2017.
//  Copyright © 2017 kzaher. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

struct DummySection {
    var title: String
    var items: [DummyItem]
}

extension DummySection: AnimatableSectionModelType {
    init(original: DummySection, items: [DummyItem]) {
        self = original
        self.items = items
    }

    var identity: String {
        return title
    }
}

struct DummyItem: IdentifiableType, Equatable {
    var identity: Int

    static func == (lhs: DummyItem, rhs: DummyItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

final class AnimatedScrollToItemExample: UIViewController {

    let sections: Variable<[DummySection]> = Variable([])
    let disposeBag: DisposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        Observable<Int>.timer(0.0, period: 3.0, scheduler: ConcurrentMainScheduler.instance)
            .map { _ in (Int(arc4random()) + 50) % 200 }
            .map { sectionCount -> [DummySection] in
                (0..<sectionCount).map { sectionIndex in
                    let item = DummyItem(identity: Int(sectionIndex))
                    return DummySection(title: "Section \(sectionIndex)", items: [item])
                }
            }
            .bind(to: sections)
            .disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedAnimatedDataSource<DummySection>(
            configureCell: { (_, tableView, indexPath, item: DummyItem) in
                let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.textLabel?.text = "I am entry in section \(item.identity)"

                return cell
            },
            titleForHeaderInSection: { dataSource, section in
                return dataSource.sectionModels[section].title
            }
        )

        dataSource.updatesCompleted
            .map { [unowned self] _ in
                self.tableView.numberOfSections
            }
            .subscribe(onNext: { [unowned self] sections in
                let randomSection = Int(arc4random()) % sections
                print("Scrolling to section: \(randomSection)")
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: randomSection), at: .top, animated: true)
            })
            .disposed(by: disposeBag)

        sections.asObservable()
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}
