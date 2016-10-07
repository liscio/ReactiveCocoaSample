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
        return indexes.map { self[$0] }
    }
}

protocol SelectionProtocol {
    associatedtype PropertyType: PropertyProtocol

    var base: Property<[PropertyType]> { get }
    var selectedIndexes: Property<[Int]> { get }
}

extension SelectionProtocol {
    var selectedProperties: Property<[Self.PropertyType]> {
        return base.combineLatest(with: selectedIndexes).map { base, indexes in
            base.elements(at: indexes)
        }
    }

    var selectedValues: Property<[Self.PropertyType.Value]> {
        return selectedProperties.map { properties in
            properties.map { $0.value }
        }
    }

    /// This is the analog to Cocoa Bindings' "selection.key" binding over an
    /// array controller
    func selection<U: Equatable>(getter: @escaping ((Self.PropertyType.Value) -> U)) -> Property<BindingValue<U>> {
        return selectedValues
            .flatMap(.latest) {
                Property(value: $0.map(getter) )
            }
            .map { BindingValue(values: $0)
        }
    }
}

extension SelectionProtocol where PropertyType: MutablePropertyProtocol {
    func set<U: Equatable>(newValue: U, setter: @escaping ((inout Self.PropertyType.Value, U) -> PropertyType.Value)) {
        for selected in selectedProperties.value {
            selected.value = setter(&selected.value, newValue)
        }
    }
}

public final class Selection<Value>: SelectionProtocol {
    typealias PropertyType = Property<Value>

    let base: Property<[PropertyType]>
    let selectedIndexes: Property<[Int]>

    init(base: Property<[PropertyType]>, selectedIndexes: Property<[Int]>) {
        self.base = base
        self.selectedIndexes = selectedIndexes
    }
}

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

public final class MutableOneToManyProperty<ContainerValue, LensedValue: Equatable>: MutablePropertyProtocol {
    let selection: MutableSelection<ContainerValue>

    typealias Getter = ((ContainerValue) -> LensedValue)
    typealias Setter = ((inout ContainerValue, LensedValue) -> ContainerValue)
    init(selection: MutableSelection<ContainerValue>, getter: @escaping Getter, setter: @escaping Setter) {

        self.selection = selection
        self.property = selection.selection(getter: getter)
        self.setter = setter

        self.token = Lifetime.Token()
        self.lifetime = Lifetime(self.token)
    }

    let property: Property<BindingValue<LensedValue>>

    let setter: Setter

    public let token: Lifetime.Token
    public let lifetime: Lifetime

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
        return self.property.signal
    }

    public var producer: SignalProducer<BindingValue<LensedValue>, NoError> {
        return self.property.producer
    }
}

public final class TrackSelection {
    let selection: MutableSelection<Track>

    init(selection: MutableSelection<Track>) {
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
            getter: { $0.albumTitle },
            setter: { (track: inout Track, title: String) -> Track in
                track.albumTitle = title
                return track
            })

        self.artist = MutableOneToManyProperty(
            selection: selection,
            getter: { $0.artist },
            setter: { (track: inout Track, title: String) -> Track in
                track.artist = title
                return track
            })

        self.trackIndex = MutableOneToManyProperty(
            selection: selection,
            getter: { $0.trackIndex },
            setter: { (track: inout Track, newValue: Int) -> Track in
                track.trackIndex = newValue
                return track
            })

        self.favorite = MutableOneToManyProperty(
            selection: selection,
            getter: { $0.favorite },
            setter: { (track: inout Track, newValue: Bool) -> Track in
                track.favorite = newValue
                return track
            })
    }

    let title: MutableOneToManyProperty<Track, String>
    let albumTitle: MutableOneToManyProperty<Track, String>
    let artist: MutableOneToManyProperty<Track, String>
    let trackIndex: MutableOneToManyProperty<Track, Int>
    let favorite: MutableOneToManyProperty<Track, Bool>

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
