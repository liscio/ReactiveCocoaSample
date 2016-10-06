//
//  TrackDetailViewModel.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

extension Collection {
    func elements(at indexes: [Self.Index]) -> [Self.Iterator.Element] {
        var subElements: [Self.Iterator.Element] = []
        for index in indexes {
            subElements.append(self[index])
        }
        return subElements
    }
}

public final class Selection<C: Collection> where C.Iterator.Element: Equatable {
    init(base: Property<C>, selectedIndexes: Property<[C.Index]>) {
        self.base = base
        self.selectedIndexes = selectedIndexes
    }

    let base: Property<C>
    let selectedIndexes: Property<[C.Index]>

    var selectedObjects: Property<[C.Iterator.Element]> {
        return base.combineLatest(with: selectedIndexes).map { base, indexes in
            base.elements(at: indexes)
        }
    }

    var value: Property<BindingValue<C.Iterator.Element>> {
        return selectedObjects.map { BindingValue(values: $0) }
    }
}

public final class MutableSelection<C: Collection> where C.Iterator.Element: MutablePropertyProtocol {
    init(base: Property<C>, selectedIndexes: Property<[C.Index]>) {
        self.base = base
        self.selectedIndexes = selectedIndexes
    }

    let base: Property<C>
    let selectedIndexes: Property<[C.Index]>

    var selectedValues: Property<[C.Iterator.Element.Value]> {
        return selectedProperties.map { properties in
            properties.map { $0.value }
        }
    }

    var selectedProperties: Property<[C.Iterator.Element]> {
        return base.combineLatest(with: selectedIndexes).map { base, indexes in
            base.elements(at: indexes)
        }
    }

    /// This is the analog to Cocoa Bindings' "selection.key" binding over an 
    /// array controller
    func selection<U: Equatable>(getter: @escaping ((C.Iterator.Element.Value) -> U)) -> Property<BindingValue<U>> {
        return selectedValues
            .flatMap(.latest) {
                Property(value: $0.map(getter) )
            }
            .map { BindingValue(values: $0)
        }
    }

    func set<U: Equatable>(newValue: U, setter: @escaping ((inout C.Iterator.Element.Value, U) -> C.Iterator.Element.Value)) {
        for selected in selectedProperties.value {
            selected.value = setter(&selected.value, newValue)
        }
    }
}

public final class MutableOneToManyProperty<ContainerValue, LensedValue: Equatable>: MutablePropertyProtocol {
    let selection: MutableSelection<[MutableProperty<ContainerValue>]>

    typealias Getter = ((ContainerValue) -> LensedValue)
    typealias Setter = ((inout ContainerValue, LensedValue) -> ContainerValue)
    init(selection: MutableSelection<[MutableProperty<ContainerValue>]>, getter: @escaping Getter, setter: @escaping Setter) {

        self.selection = selection
        self.property = selection.selection(getter: getter)
        self.setter = setter

        self.token = Lifetime.Token()
        self.lifetime = Lifetime(self.token)
    }

    let property: Property<Value>
    let setter: Setter

    public let token: Lifetime.Token
    public let lifetime: Lifetime

    public typealias Value = BindingValue<LensedValue>

    public var value: Value {
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
        return self.property.signal
    }

    public var producer: SignalProducer<BindingValue<LensedValue>, NoError> {
        return self.property.producer
    }
}

public final class TrackSelection {
    let selection: MutableSelection<[MutableProperty<Track>]>

    init(selection: MutableSelection<[MutableProperty<Track>]>) {
        token = Lifetime.Token()
        lifetime = Lifetime(token)

        self.selection = selection

        self.title = MutableOneToManyProperty(
            selection: selection,
            getter: { $0.title },
            setter: { (track: inout Track, title: String) -> Track in
                track.title = title
                return track
            })

        self.albumTitle = MutableOneToManyProperty(
            selection: selection,
            getter: { $0.title },
            setter: { (track: inout Track, title: String) -> Track in
                track.title = title
                return track
            })
    }

    let title: MutableOneToManyProperty<Track, String>
    let albumTitle: MutableOneToManyProperty<Track, String>

    private let token: Lifetime.Token
    private let lifetime: Lifetime
}

public final class TrackDetailViewModel {
    public let title: MutableProperty<String>
    public let artist: MutableProperty<String>
    public let albumTitle: MutableProperty<String>
    public let trackIndex: MutableProperty<Int>
    public let favorite: MutableProperty<Bool>

    private var track: Track
    private let dataSource: TrackDataSource
    init(track: Track, dataSource: TrackDataSource) {
        self.dataSource = dataSource

        // Initialize all our properties with the current values of the supplied track model object.
        title = MutableProperty(track.title)
        artist = MutableProperty(track.artist)
        albumTitle = MutableProperty(track.albumTitle)
        trackIndex = MutableProperty(track.trackIndex)
        favorite = MutableProperty(track.favorite)

        self.track = track
        _editedTrack = MutableProperty(track)
        editedTrack = Property(_editedTrack)
    }

    private let _editedTrack: MutableProperty<Track>
    public let editedTrack: Property<Track>

    func commitEditing() {
        track = Track(
            title: title.value,
            albumTitle: albumTitle.value,
            artist: artist.value,
            trackIndex: trackIndex.value,
            favorite: favorite.value)
        _editedTrack.value = track

        dataSource.replaceSelectedTrack(with: track)
    }

    func revert() {
        _editedTrack.value = track
        title.value = track.title
        artist.value = track.artist
        albumTitle.value = track.albumTitle
        trackIndex.value = track.trackIndex
        favorite.value = track.favorite
    }
}
