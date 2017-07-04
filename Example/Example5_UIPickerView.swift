//
//  Example5_UIPickerView.swift
//  RxDataSources
//
//  Created by Sergey Shulga on 04/07/2017.
//  Copyright © 2017 kzaher. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

final class ReactivePickerViewControllerExample: UIViewController {
    
    @IBOutlet weak var firstPickerView: UIPickerView!
    @IBOutlet weak var secondPickerView: UIPickerView!
    @IBOutlet weak var thirdPickerView: UIPickerView!
    
    let disposeBag = DisposeBag()
    
    private let stringPickerAdapter = RxPickerViewStringAdapter<[String]>(components: [])
    private let attributedStringPickerAdapter = RxPickerViewAttributedStringAdapter<[String]>(components: [])
    private let viewPickerAdapter = RxPickerViewViewAdapter<[String]>(components: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStringPickerAdapter()
        setupAttributedStringPickerAdapter()
        setupViewPickerAdapter()
        
        Observable.just(["One", "Two", "Tree"])
            .bind(to: firstPickerView.rx.items(adapter: stringPickerAdapter))
            .disposed(by: disposeBag)
        
        Observable.just(["One", "Two", "Tree"])
            .bind(to: secondPickerView.rx.items(adapter: attributedStringPickerAdapter))
            .disposed(by: disposeBag)
        
        Observable.just(["One", "Two", "Tree"])
            .bind(to: thirdPickerView.rx.items(adapter: viewPickerAdapter))
            .disposed(by: disposeBag)
    }
    
    func setupStringPickerAdapter() {
        stringPickerAdapter.numberOfComponentsProvider = { _ in
            return 1
        }
        
        stringPickerAdapter.numberOfRowsInComponentProvider = { _, _, components, _ in
            return components.count
        }
        
        stringPickerAdapter.titleForRowProvider = { _, _, components, row, _ in
            return components[row]
        }
    }
    
    func setupAttributedStringPickerAdapter() {
        attributedStringPickerAdapter.numberOfComponentsProvider = { _ in
            return 1
        }
        
        attributedStringPickerAdapter.numberOfRowsInComponentProvider = { _, _, components, _ in
            return components.count
        }
        
        attributedStringPickerAdapter.attributedTitleForRowProvider = {_, _, components, row, _ in
            let string = components[row]
            return NSAttributedString(string: string,
                                      attributes: [
                                        NSForegroundColorAttributeName: UIColor.purple,
                                        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleDouble.rawValue,
                                        NSTextEffectAttributeName: NSTextEffectLetterpressStyle
                                    ])
        }
    }
    
    func setupViewPickerAdapter() {
        viewPickerAdapter.numberOfComponentsProvider = { _ in
            return 1
        }
        
        viewPickerAdapter.numberOfRowsInComponentProvider = { _, _, components, _ in
            return components.count
        }
        
        viewPickerAdapter.viewForRowProvider = { _, _, components, row, _, view in
            let componentView = view ?? UIView()
            componentView.backgroundColor = row % 2 == 0 ? UIColor.red : UIColor.blue
            return componentView
        }
    }
}
