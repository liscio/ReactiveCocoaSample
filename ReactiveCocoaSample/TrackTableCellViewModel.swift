//
//  TrackTableCellViewModel.swift
//  ReactiveCocoaSample
//
//  Created by Christopher Liscio on 10/5/16.
//  Copyright © 2016 SuperMegaUltraGroovy, Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

/// The view model for a table cell view is far simpler, as it has no need to expose *all* the values of the Track it is displaying.
public final class TrackTableCellViewModel {
    public let trackIndex: Property<Int>
    public let title: Property<String>
    public let artist: Property<String>
    public let favorite: Property<Bool>

    init(track: Track) {
        trackIndex = Property(value: track.trackIndex)
        title = Property(value: track.title)
        artist = Property(value: track.artist)
        favorite = Property(value: track.favorite)
    }
}
