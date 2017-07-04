//
//  RxPickerViewAdapter.swift
//  RxDataSources
//
//  Created by Sergey Shulga on 04/07/2017.
//  Copyright © 2017 kzaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

public protocol RxPickerViewDataSourceType {
    /// Type of elements that can be bound to table view.
    associatedtype Element
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>)
}

open class RxPickerViewDataSource<T>: NSObject, UIPickerViewDataSource {
    public typealias NumberOfComponentsProvider = (RxPickerViewDataSource, UIPickerView, T) -> Int
    public typealias NumberOfRowsInComponentProvider = (RxPickerViewDataSource, UIPickerView, T, Int) -> Int
    
    fileprivate var components: T
    
    init(components: T) {
        self.components = components
        super.init()
    }
    
    public var numberOfComponentsProvider: NumberOfComponentsProvider!
    public var numberOfRowsInComponentProvider: NumberOfRowsInComponentProvider!
    
    //MARK: UIPickerViewDataSource
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponentsProvider(self, pickerView, components)
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfRowsInComponentProvider(self, pickerView, components, component)
    }
}

extension RxPickerViewDataSource: RxPickerViewDataSourceType {
    public func pickerView(_ pickerView: UIPickerView, observedEvent: Event<T>) {
        UIBindingObserver(UIElement: self) { (dataSource, components) in
            dataSource.components = components
            pickerView.reloadAllComponents()
        }.on(observedEvent)
    }
}

open class RxPickerViewStringAdapter<T>: RxPickerViewDataSource<T>, UIPickerViewDelegate {
    public typealias TitleForRowProvider = (RxPickerViewStringAdapter<T>, UIPickerView, T,Int, Int) -> String?
    
    public var titleForRowProvider: TitleForRowProvider! = nil
    
    public override init(components: T) {
        super.init(components: components)
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleForRowProvider(self, pickerView, components, row, component)
    }
}

open class RxPickerViewAttributedStringAdapter<T>: RxPickerViewDataSource<T>, UIPickerViewDelegate {
    public typealias AttributedTitleForRowProvider = (RxPickerViewAttributedStringAdapter<T>, UIPickerView, T, Int, Int) -> NSAttributedString?
    
    public var attributedTitleForRowProvider: AttributedTitleForRowProvider! = nil
    
    public override init(components: T) {
        super.init(components: components)
    }
    
    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return attributedTitleForRowProvider(self, pickerView, components, row, component)
    }
}

open class RxPickerViewViewAdapter<T>: RxPickerViewDataSource<T>, UIPickerViewDelegate {
    public typealias ViewForRowProvider = (RxPickerViewViewAdapter<T>, UIPickerView, T, Int, Int, UIView?) -> UIView
    
    public var viewForRowProvider: ViewForRowProvider!
    
    public override init(components: T) {
        super.init(components: components)
    }
    
    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return viewForRowProvider(self, pickerView, components, row, component, view)
    }
}

extension Reactive where Base: UIPickerView {
    public func items<O: ObservableType,
                         Adapter: RxPickerViewDataSourceType & UIPickerViewDataSource & UIPickerViewDelegate>(adapter: Adapter)
        -> (_ source: O)
        -> Disposable where O.E == Adapter.Element {
            return { source in
                self.base.delegate = adapter
                self.base.dataSource = adapter
                return source.subscribe{ [weak pickerView = self.base] (event) in
                    guard let pickerView = pickerView else { return }
                    adapter.pickerView(pickerView, observedEvent: event)
                }
            }
    }
}

