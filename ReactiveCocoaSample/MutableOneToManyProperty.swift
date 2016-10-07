//
//  MutableOneToManyProperty.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 2016-10-06.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

/// Represents a one-to-many relationship between a `ViewModel` or other
/// object controller and a selection of one or more values.
public final class MutableOneToManyProperty<ContainerValue, LensedValue: Equatable> {

    /// The underlying selection object that allows us to monitor changes to, 
    /// and modify a collection of mutable properties
    fileprivate let selection: MutableSelection<ContainerValue>

    typealias Getter = ((ContainerValue) -> LensedValue)
    typealias Setter = ((inout ContainerValue, LensedValue) -> ContainerValue)

    /// Creates a new mutable to-many relationship with the given selection 
    /// controller, using the given getter and setter objects to access the
    /// individual elements in the collection.
    init(selection: MutableSelection<ContainerValue>, getter: @escaping Getter, setter: @escaping Setter) {
        self.selection = selection
        self.property = selection.selection(getter: getter)
        self.setter = setter

        self.token = Lifetime.Token()
        self.lifetime = Lifetime(self.token)
    }

    /// This is the underlying property that will update as the selection 
    /// object changes, and supply values for the `signal` and `producer`
    fileprivate let property: Property<BindingValue<LensedValue>>

    /// The setter is saved so that it may be applied when the `value` is set
    /// over the entire selection.
    fileprivate let setter: Setter

    private let token: Lifetime.Token
    public let lifetime: Lifetime
}

extension MutableOneToManyProperty: MutablePropertyProtocol {
    public var value: BindingValue<LensedValue> {
        get {
            return property.value
        }
        set {
            if case let .value(v) = newValue {
                selection.set(newValue: v, setter: setter)
            }
            else {
                fatalError("Cannot set a placeholder value on a selection")
            }
        }
    }

    public var signal: Signal<BindingValue<LensedValue>, NoError> {
        return property.signal
    }

    public var producer: SignalProducer<BindingValue<LensedValue>, NoError> {
        return property.producer
    }
}
