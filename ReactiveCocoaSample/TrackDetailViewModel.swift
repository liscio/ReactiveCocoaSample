//
//  TrackDetailViewModel.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

public final class TrackSelection {
    public let title: MutableOneToManyProperty<Track, String>
    public let albumTitle: MutableOneToManyProperty<Track, String>
    public let artist: MutableOneToManyProperty<Track, String>
    public let trackIndex: MutableOneToManyProperty<Track, Int>
    public let favorite: MutableOneToManyProperty<Track, Bool>

    private let selection: MutableSelection<Track>
    public init(selection: MutableSelection<Track>) {
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

    private let token: Lifetime.Token
    private let lifetime: Lifetime
}
