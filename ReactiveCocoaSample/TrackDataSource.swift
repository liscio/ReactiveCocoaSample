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

extension Int {
    static var noSelection: Int {
        return -1
    }
}

final class TrackDataSource {
    private let _tracks = MutableProperty<[Track]>([])
    let tracks: Property<[Track]>

    let selectedIndex = MutableProperty<Int>(.noSelection)
    let selectedTrack: Property<Track?>

    init() {
        tracks = Property(_tracks)
        selectedTrack = tracks.combineLatest(with: selectedIndex).map { $1 >= 0 ? $0[$1] : nil }

        // Put some dummy values in for now
        _tracks.value = [
            Track(title: "Hello, World!", albumTitle: "Songs To Code By", artist: "Foo McBar", trackIndex: 4, favorite: false),
            Track(title: "Infinite Loops", albumTitle: "Songs To Code By", artist: "Foo McBar", trackIndex: 3, favorite: false),
        ]
    }

    func insertNewTrack() {
        _tracks.modify { (tracks: inout [Track]) -> [Track] in
            tracks.append(.placeholder)
            return tracks
        }
    }

    func replaceSelectedTrack(with track: Track) {
        _tracks.modify { (tracks: inout [Track]) -> [Track] in
            if selectedIndex.value >= 0 {
                tracks[selectedIndex.value] = track
            }

            return tracks
        }
    }
}
