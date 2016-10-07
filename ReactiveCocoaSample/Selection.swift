//
//  Selection.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 2016-10-06.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

/// Represents a selection in a `base` collection of properties.
protocol SelectionProtocol {
    associatedtype PropertyType: PropertyProtocol

    /// The collection of properties that is indexed by `selectedIndexes`
    var base: Property<[PropertyType]> { get }

    /// The set of selected indexes within the `base` collection of properties
    var selectedIndexes: Property<[Int]> { get }
}

extension SelectionProtocol {
    /// The selected set of properties in the `base` collection
    var selectedProperties: Property<[Self.PropertyType]> {
        return base.combineLatest(with: selectedIndexes).map { base, indexes in
            base.elements(at: indexes)
        }
    }

    /// The underlying values that are currently selected
    var selectedValues: Property<[Self.PropertyType.Value]> {
        return selectedProperties.map { properties in
            properties.map { $0.value }
        }
    }

    /// Returns an array using the given `getter` to extract individual values 
    /// from the underlying selected objects.
    ///
    /// - note: This is similar to monitoring the "selection.key" key path in
    ///         an NSArrayController in Cocoa.
    func selection<U>(getter: @escaping ((Self.PropertyType.Value) -> U)) -> Property<[U]> {
        return selectedValues.flatMap(.latest) { Property(value: $0.map(getter) ) }
    }

    /// Returns a `BindingValue` placeholder using the given `getter` to extract
    /// individual values from the underlying objects.
    ///
    /// - note: This is similar to monitoring the "selection.key" key path in 
    ///         an NSArrayController in Cocoa when using placeholder values.
    func selection<U: Equatable>(getter: @escaping ((Self.PropertyType.Value) -> U)) -> Property<BindingValue<U>> {
        return selection(getter: getter).map { BindingValue(values: $0) }
    }
}

extension SelectionProtocol where PropertyType: MutablePropertyProtocol {
    /// Using the supplied `setter`, applies `newValue` on all the selected 
    /// properties.
    func set<U: Equatable>(newValue: U, setter: @escaping ((inout Self.PropertyType.Value, U) -> PropertyType.Value)) {
        for selected in selectedProperties.value {
            selected.value = setter(&selected.value, newValue)
        }
    }
}

/// Represents a selection of properties that can be monitored for changes
public final class Selection<Value>: SelectionProtocol {
    typealias PropertyType = Property<Value>

    let base: Property<[PropertyType]>
    let selectedIndexes: Property<[Int]>

    init(base: Property<[PropertyType]>, selectedIndexes: Property<[Int]>) {
        self.base = base
        self.selectedIndexes = selectedIndexes
    }
}

/// Represents a selection of properties that can be monitored for changes, and
/// modified individually or as a group
public final class MutableSelection<Value>: SelectionProtocol {
    typealias PropertyType = MutableProperty<Value>
    typealias Base = Property<[PropertyType]>

    let base: Base
    let selectedIndexes: Property<[Int]>

    init(base: Base, selectedIndexes: Property<[Int]>) {
        self.base = base
        self.selectedIndexes = selectedIndexes
    }
}

private extension Collection {
    func elements(at indexes: [Self.Index]) -> [Self.Iterator.Element] {
        return indexes.map { self[$0] }
    }
}

private extension Collection where Self.Index == Int {
    func elements(at indexes: IndexSet) -> [Self.Iterator.Element] {
        return elements(at: indexes.map { $0 })
    }
}
