//
//  TrackDetailViewModel.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.NoError

public final class TrackDetailViewModel {
    public let title: MutableProperty<String>
    public let artist: MutableProperty<String>
    public let albumTitle: MutableProperty<String>
    public let trackIndex: MutableProperty<Int>
    public let favorite: MutableProperty<Bool>

    private var track: Track
    init(track: Track) {
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
