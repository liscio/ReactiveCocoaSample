//
//  TrackDataSource.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 2016-10-05.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

extension Track {
    static var placeholder: Track {
        return Track(title: "Title", albumTitle: "Album", artist: "Artist", trackIndex: 0, favorite: false)
    }
}

final class TrackDataSource {
    private let _tracks = MutableProperty<[MutableProperty<Track>]>([])
    let tracks: Property<[MutableProperty<Track>]>

    let selectedIndexes = MutableProperty<[Int]>([])

    let selection: MutableSelection<Track>

    init() {
        tracks = Property(_tracks)

        selection = MutableSelection<Track>(base: tracks, selectedIndexes: Property(selectedIndexes))

        // Put some dummy values in for now
        _tracks.value = [
            MutableProperty(Track(title: "Hello, World!", albumTitle: "Songs To Code By", artist: "Foo McBar", trackIndex: 4, favorite: false)),
            MutableProperty(Track(title: "Infinite Loops", albumTitle: "Songs To Code By", artist: "Foo McBar", trackIndex: 3, favorite: false)),
        ]
    }

    func insertNewTrack() {
        _tracks.modify { (tracks: inout [MutableProperty<Track>]) -> [MutableProperty<Track>] in
            tracks.append(MutableProperty(.placeholder))
            return tracks
        }
    }
}
